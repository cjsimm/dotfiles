-- Keep Neovim splits and Herdr panes on the same Ctrl-h/j/k/l navigation
-- plane. Herdr forwards these chords to Neovim when it is foregrounded; at a
-- Neovim split edge this module hands focus back to the adjacent Herdr pane.
--
-- Outside Herdr, retain the existing vim-tmux-navigator behavior when tmux is
-- present, and otherwise use ordinary Neovim window navigation.
local M = {}

local tmux_directions = {
	left = "Left",
	down = "Down",
	up = "Up",
	right = "Right",
}

local function focus_herdr(direction)
	local herdr = vim.env.HERDR_BIN_PATH
	if not herdr or herdr == "" then
		herdr = "herdr"
	end

	vim.system({ herdr, "pane", "focus", "--direction", direction, "--current" }, { detach = true })
end

local function navigate(wincmd, direction)
	local previous_window = vim.api.nvim_get_current_win()
	vim.cmd("wincmd " .. wincmd)
	if vim.api.nvim_get_current_win() ~= previous_window then
		return
	end

	if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
		focus_herdr(direction)
	elseif vim.env.TMUX and vim.env.TMUX ~= "" then
		pcall(vim.cmd, "TmuxNavigate" .. tmux_directions[direction])
	end
end

function M.setup()
	local mappings = {
		{ "<C-h>", "h", "left" },
		{ "<C-j>", "j", "down" },
		{ "<C-k>", "k", "up" },
		{ "<C-l>", "l", "right" },
	}

	for _, mapping in ipairs(mappings) do
		vim.keymap.set("n", mapping[1], function()
			navigate(mapping[2], mapping[3])
		end, { desc = "Navigate " .. mapping[3] .. " (Neovim/Herdr)", noremap = true, silent = true })
	end
end

return M
