-- CodeCompanion -> Herdr lifecycle bridge.
--
-- Neovim is the foreground process in a Herdr pane, so Herdr cannot infer the
-- nested Codex ACP agent's lifecycle from the terminal screen. CodeCompanion
-- already exposes that lifecycle as User autocmds; this module reduces those
-- events into Herdr's semantic idle, working, and blocked states.
--
-- Herdr allows one lifecycle authority per pane. The Codex ACP child therefore
-- runs with its session-only Herdr hook disabled, while this Neovim process
-- reports the complete lifecycle under SOURCE.
local M = {}

local SOURCE = "user:codecompanion"
local AGENT = "codex"

---@class CodeCompanionHerdr.ChatState
---@field blocked boolean Whether Codex is waiting for user approval.
---@field compacting boolean Whether chat context compaction is active.
---@field message? string Human-readable context for the current state.
---@field requests table<string, boolean> Active CodeCompanion request IDs.
---@field submitted boolean Fallback working flag between chat submission and completion.
---@field tools table<string, boolean> Active individual tool IDs.
---@field tools_batch boolean Whether CodeCompanion's tool orchestrator is active.

---@class CodeCompanionHerdr.Command
---@field args string[] Command and arguments passed to vim.system.

-- State is tracked per chat buffer because CodeCompanion can keep several
-- chats alive in one Neovim instance. refresh() rolls them up to one pane.
---@type table<integer, CodeCompanionHerdr.ChatState>
local chats = {}

-- Module/reporting state.
local enabled = false
local herdr_path
local last_requested_state
local reported = false
local warned = false
---@type CodeCompanionHerdr.Command[]
local command_queue = {}
local command_running = false
local last_seq

-- Report transport -----------------------------------------------------------

---Create a strictly increasing u64-compatible sequence for Herdr reports.
---
---Herdr rejects stale reports from the same source. The value stays a decimal
---string because a nanosecond Unix timestamp is too large for lossless
---representation by every Lua number implementation.
---@return string seq
local function next_seq()
	local seconds, microseconds = vim.uv.gettimeofday()
	local candidate = string.format("%d%06d000", seconds, microseconds)

	-- Events can share a microsecond. Herdr requires a strictly increasing u64
	-- sequence per source, so increment the decimal string without converting
	-- the nanosecond timestamp to a lossy Lua number.
	if last_seq and candidate <= last_seq then
		local digits = {}
		local carry = 1
		for index = #last_seq, 1, -1 do
			local digit = tonumber(last_seq:sub(index, index)) + carry
			if digit == 10 then
				digit = 0
				carry = 1
			else
				carry = 0
			end
			table.insert(digits, 1, tostring(digit))
		end
		if carry == 1 then
			table.insert(digits, 1, "1")
		end
		candidate = table.concat(digits)
	end

	last_seq = candidate
	return candidate
end

---Show the first bridge failure without repeatedly interrupting the editor.
---@param message string
local function warn_once(message)
	if warned then
		return
	end

	warned = true
	vim.schedule(function()
		vim.notify(message, vim.log.levels.WARN, { title = "CodeCompanion → Herdr" })
	end)
end

---Run the next queued Herdr command, preserving lifecycle event order.
---
---Each completion advances the queue. Herdr sequence numbers also protect
---against stale reports, but serialization makes ordering deterministic before
---the requests reach Herdr.
local function run_next()
	if command_running or #command_queue == 0 then
		return
	end

	command_running = true
	local command = table.remove(command_queue, 1)
	vim.system(command.args, {}, function(result)
		command_running = false
		if result.code ~= 0 then
			local detail = vim.trim(result.stderr or "")
			if detail ~= "" then
				detail = ": " .. detail
			end
			warn_once("Unable to report agent state" .. detail)
		end
		run_next()
	end)
end

---Append a Herdr CLI invocation to the serialized command queue.
---@param args string[]
local function enqueue(args)
	table.insert(command_queue, { args = args })
	run_next()
end

---Report a semantic pane state unless that state was already requested.
---@param state "idle"|"working"|"blocked"|"unknown"
---@param message string
local function report(state, message)
	if state == last_requested_state then
		return
	end

	last_requested_state = state
	reported = true
	enqueue({
		herdr_path,
		"pane",
		"report-agent",
		vim.env.HERDR_PANE_ID,
		"--source",
		SOURCE,
		"--agent",
		AGENT,
		"--state",
		state,
		"--message",
		message,
		"--seq",
		next_seq(),
	})
end

---Give up this module's lifecycle authority for the pane.
---
---Normal releases use the command queue. VimLeavePre uses a detached process
---so the release can finish after Neovim exits.
---@param detach? boolean
local function release(detach)
	if not reported then
		return
	end

	reported = false
	last_requested_state = nil
	local args = {
		herdr_path,
		"pane",
		"release-agent",
		vim.env.HERDR_PANE_ID,
		"--source",
		SOURCE,
		"--agent",
		AGENT,
		"--seq",
		next_seq(),
	}

	if detach then
		-- A higher sequence makes this safe even if an older queued report
		-- reaches Herdr after Neovim has begun exiting.
		vim.system(args, { detach = true })
	else
		enqueue(args)
	end
end

-- State aggregation ----------------------------------------------------------

---Return whether a map contains at least one entry.
---@param items? table
---@return boolean
local function has_items(items)
	return items and next(items) ~= nil
end

---Return whether any activity flag makes a chat semantically working.
---@param state CodeCompanionHerdr.ChatState
---@return boolean
local function is_working(state)
	return state.submitted
		or state.compacting
		or state.tools_batch
		or has_items(state.requests)
		or has_items(state.tools)
end

---Aggregate every tracked chat and publish the pane's highest-priority state.
---
---Priority is blocked > working > idle. With no Codex chats left, the bridge
---releases the pane instead of leaving behind a phantom idle agent.
local function refresh()
	local has_chat = false
	local has_working = false
	local working_message

	for _, state in pairs(chats) do
		has_chat = true
		if state.blocked then
			report("blocked", state.message or "Codex needs approval")
			return
		end
		if is_working(state) then
			has_working = true
			working_message = working_message or state.message
		end
	end

	if has_working then
		report("working", working_message or "Codex is working in Neovim")
	elseif has_chat then
		report("idle", "Codex is ready in Neovim")
	else
		release(false)
	end
end

-- CodeCompanion event reduction ---------------------------------------------

---Return the Codex ACP chat attached to a buffer, if one exists.
---@param bufnr integer
---@return CodeCompanion.Chat|nil
local function codex_chat(bufnr)
	local ok, codecompanion = pcall(require, "codecompanion")
	if not ok then
		return nil
	end

	local chat = codecompanion.buf_get_chat(bufnr)
	if not chat or not chat.adapter then
		return nil
	end

	if chat.adapter.type ~= "acp" or chat.adapter.name ~= "codex" then
		return nil
	end

	return chat
end

---Extract the chat buffer number from a CodeCompanion User event.
---@param args table
---@return integer|nil
local function event_bufnr(args)
	return args.data and args.data.bufnr or args.buf
end

---Create the lifecycle accumulator for one CodeCompanion chat.
---@return CodeCompanionHerdr.ChatState
local function new_state()
	return {
		blocked = false,
		compacting = false,
		requests = {},
		submitted = false,
		tools = {},
		tools_batch = false,
	}
end

---Reset all transient activity while keeping the chat registered as idle.
---@param state CodeCompanionHerdr.ChatState
local function clear_activity(state)
	state.blocked = false
	state.compacting = false
	state.message = nil
	state.requests = {}
	state.submitted = false
	state.tools = {}
	state.tools_batch = false
end

---Check that a generic request event belongs to Codex ACP chat.
---
---Request events are global to CodeCompanion, so this prevents Gemini inline
---and command requests from changing the Herdr agent state.
---@param args table
---@return boolean
local function request_is_codex(args)
	local data = args.data or {}
	local adapter = data.adapter or {}
	return data.interaction == "chat" and adapter.type == "acp" and adapter.name == "codex"
end

---Return a stable map key for a request event.
---@param args table
---@return string
local function request_key(args)
	local data = args.data or {}
	return tostring(data.id or "request")
end

---Return a stable map key for an individual tool event.
---@param args table
---@return string
local function tool_key(args)
	local data = args.data or {}
	return tostring(data.id or data.tool or data.name or "tool")
end

---Reduce one CodeCompanion lifecycle event into per-chat state.
---
---This callback first filters events to Codex ACP, then updates only the
---activity dimension represented by that event. refresh() performs the final
---cross-chat rollup and Herdr report.
---@param args table Neovim User-autocmd callback arguments.
local function on_event(args)
	local bufnr = event_bufnr(args)
	if not bufnr then
		return
	end

	local match = args.match
	local chat = codex_chat(bufnr)
	local state = chats[bufnr]

	if match == "CodeCompanionChatClosed" then
		if state then
			chats[bufnr] = nil
			refresh()
		end
		return
	end

	if match == "CodeCompanionChatAdapter" then
		if not chat then
			chats[bufnr] = nil
			refresh()
			return
		end
	elseif match:find("^CodeCompanionRequest") and not request_is_codex(args) then
		return
	elseif not chat and not state then
		return
	end

	state = state or new_state()
	chats[bufnr] = state

	if
		match == "CodeCompanionChatCreated"
		or match == "CodeCompanionChatOpened"
		or match == "CodeCompanionChatAdapter"
		or match == "CodeCompanionACPConnected"
		or match == "CodeCompanionACPChatRestored"
	then
		-- Register the pane before Codex starts, so CodeCompanion is the sole
		-- lifecycle authority for this Neovim-hosted agent.
	elseif match == "CodeCompanionChatSubmitted" then
		state.submitted = true
		state.message = "Codex is working in Neovim"
	elseif match == "CodeCompanionChatCompacting" then
		state.compacting = true
		state.message = "Codex is compacting the chat"
	elseif match == "CodeCompanionRequestStarted" or match == "CodeCompanionRequestStreaming" then
		state.requests[request_key(args)] = true
		state.submitted = true
		state.message = "Codex is working in Neovim"
	elseif match == "CodeCompanionRequestFinished" then
		state.requests[request_key(args)] = nil
		state.submitted = false
		state.compacting = false
		state.message = nil
	elseif match == "CodeCompanionToolsStarted" then
		state.tools_batch = true
		state.message = "Codex is running tools"
	elseif match == "CodeCompanionToolStarted" then
		state.tools[tool_key(args)] = true
		local name = args.data and (args.data.tool or args.data.name)
		state.message = name and ("Codex is running: " .. name) or "Codex is running a tool"
	elseif match == "CodeCompanionToolFinished" then
		state.tools[tool_key(args)] = nil
	elseif match == "CodeCompanionToolsFinished" then
		state.tools_batch = false
		state.tools = {}
		state.message = nil
	elseif match == "CodeCompanionToolApprovalRequested" then
		local name = args.data and args.data.name
		state.blocked = true
		state.message = name and ("Codex needs approval: " .. name) or "Codex needs approval"
	elseif match == "CodeCompanionToolApprovalFinished" then
		state.blocked = false
		state.message = is_working(state) and "Codex is working in Neovim" or nil
	elseif
		match == "CodeCompanionChatDone"
		or match == "CodeCompanionChatStopped"
		or match == "CodeCompanionChatCleared"
		or match == "CodeCompanionChatRestored"
	then
		clear_activity(state)
	else
		return
	end

	refresh()
end

-- Public API ----------------------------------------------------------------

---Prevent the nested Codex ACP process from installing Herdr's session-only
---hook. Neovim keeps HERDR_ENV=1 and this module owns the full lifecycle.
---
---Without this environment override, Codex claims `herdr:codex` authority
---before CodeCompanion can report state. Herdr then correctly rejects this
---module as a second, conflicting authority.
---@param env table<string, string>
---@return table<string, string>
function M.codex_env(env)
	env = vim.deepcopy(env or {})
	if vim.env.HERDR_ENV == "1" then
		env.HERDR_ENV = "0"
	end
	return env
end

---Enable the bridge when Neovim is running inside a Herdr pane.
---
---Registers only lifecycle-bearing CodeCompanion events. Display-only events
---such as model changes and file edits do not alter Herdr's semantic state.
function M.setup()
	if enabled or vim.env.HERDR_ENV ~= "1" or not vim.env.HERDR_PANE_ID then
		return
	end

	herdr_path = vim.env.HERDR_BIN_PATH
	if not herdr_path or herdr_path == "" or vim.fn.executable(herdr_path) ~= 1 then
		herdr_path = vim.fn.exepath("herdr")
	end
	if herdr_path == "" then
		warn_once("Herdr is not available on Neovim's PATH")
		return
	end

	enabled = true
	local group = vim.api.nvim_create_augroup("CodeCompanionHerdr", { clear = true })

	-- Event families:
	--   chat/ACP creation and restoration -> register idle
	--   submission, requests, compaction, and tools -> working
	--   approval request/finish -> blocked/working
	--   completion, stop, clear, and restore -> idle
	--   close -> release after the final Codex chat closes
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = {
			"CodeCompanionACPConnected",
			"CodeCompanionACPChatRestored",
			"CodeCompanionChatCreated",
			"CodeCompanionChatOpened",
			"CodeCompanionChatAdapter",
			"CodeCompanionChatSubmitted",
			"CodeCompanionChatCompacting",
			"CodeCompanionChatDone",
			"CodeCompanionChatStopped",
			"CodeCompanionChatCleared",
			"CodeCompanionChatRestored",
			"CodeCompanionChatClosed",
			"CodeCompanionRequestStarted",
			"CodeCompanionRequestStreaming",
			"CodeCompanionRequestFinished",
			"CodeCompanionToolsStarted",
			"CodeCompanionToolsFinished",
			"CodeCompanionToolStarted",
			"CodeCompanionToolFinished",
			"CodeCompanionToolApprovalRequested",
			"CodeCompanionToolApprovalFinished",
		},
		callback = on_event,
		desc = "Report CodeCompanion Codex lifecycle to Herdr",
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			release(true)
		end,
		desc = "Release CodeCompanion's Herdr agent state",
	})
end

return M
