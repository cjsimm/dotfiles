return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        'nvim-treesitter/nvim-treesitter',
    },
    config = function()
        local codecompanion_herdr = require("config.codecompanion_herdr")
        local acp = require("codecompanion.acp")

        local function change_reasoning(chat)
            if not chat.acp_connection then
                vim.notify("No active ACP connection", vim.log.levels.WARN)
                return
            end

            local reasoning_option
            for _, option in ipairs(chat.acp_connection:get_config_options()) do
                if option.category == "thought_level"
                    or option.id == "thought_level"
                    or option.id == "reasoning_effort" then
                    reasoning_option = option
                    break
                end
            end

            if not reasoning_option then
                vim.notify("Codex did not advertise a reasoning-level option", vim.log.levels.WARN)
                return
            end

            local values = acp.flatten_config_options(reasoning_option.options or {})
            local choices = {}
            local value_map = {}
            for index, value in ipairs(values) do
                local prefix = value.value == reasoning_option.currentValue and "* " or "  "
                choices[index] = prefix .. value.name
                value_map[index] = value
            end

            vim.ui.select(choices, {
                kind = "codecompanion.nvim",
                prompt = "Reasoning effort",
            }, function(_, index)
                if not index then
                    return
                end

                local selected = value_map[index]
                if selected.value == reasoning_option.currentValue then
                    return
                end

                if chat.acp_connection:set_config_option(reasoning_option.id, selected.value) then
                    vim.notify("Codex reasoning effort: " .. selected.name, vim.log.levels.INFO)
                    if chat.update_metadata then
                        chat:update_metadata()
                    end
                else
                    vim.notify("Failed to change Codex reasoning effort", vim.log.levels.ERROR)
                end
            end)
        end

        -- Chat-buffer built-ins (active while the CodeCompanion chat is focused):
        --   <C-s> in Insert mode / <CR> in Normal mode: submit the current message.
        --   q: stop the active request.  ga: choose an adapter/model.
        --   gm: add a message while the agent is working.  gr: regenerate the reply.
        --   ?: show all chat-buffer keymaps.  See :help codecompanion-chat for more.

        -- Keep Gemini for stateless interactions; ACP adapters support chat only.
        local gemini_default = {
            name = "gemini",
            model = "gemini-2.5-flash",
        }
        require("codecompanion").setup({
            adapters = {
                acp = {
                    codex = function()
                        return require("codecompanion.adapters").extend("codex", {
                            defaults = {
                                auth_method = "chat-gpt",
                            },
                            -- Keep Neovim as Herdr's sole lifecycle authority;
                            -- the nested Codex ACP process must not claim the pane.
                            env = codecompanion_herdr.codex_env({
                                CODEX_PATH = "/opt/homebrew/bin/codex",
                            }),
                        })
                    end,
                },
                http = {
                    gemini = function()
                        return require("codecompanion.adapters").extend("gemini", {
                            -- Gemini 2.5 Flash rejects `thinkingLevel`; CodeCompanion
                            -- otherwise adds it with a default of "high".
                            schema = {
                                thinkingLevel = {
                                    enabled = function()
                                        return false
                                    end,
                                },
                            },
                        })
                    end,
                },
            },
            prompt_library = {
                markdown = {
                    dirs = {
                        vim.fn.stdpath("config") .. "/prompts/codecompanion",
                    },
                },
            },
            interactions = {
                chat = {
                    adapter = "codex",
                    keymaps = {
                        change_reasoning = {
                            modes = {
                                n = "<leader>ar",
                            },
                            callback = change_reasoning,
                            description = "Change Codex reasoning effort",
                        },
                    },
                },
                inline = {
                    adapter = gemini_default
                },
                cmd = {
                    adapter = gemini_default
                },
            },
            opts = {
                log_level = "DEBUG",
            },
        })
        -- Subscribe after CodeCompanion has defined its adapters and events.
        codecompanion_herdr.setup()

        -- Codex Keymaps
        vim.keymap.set(
            { "n", "v" },
            "<leader>ac",
            "<cmd>CodeCompanionChat Toggle<cr>",
            { desc = "AI: Toggle Codex chat" }
        )
        vim.keymap.set(
            "n",
            "<leader>an",
            "<cmd>CodeCompanionChat<cr>",
            { desc = "AI: New Codex chat" }
        )
        vim.keymap.set(
            { "n", "v" },
            "<leader>aa",
            "<cmd>CodeCompanionActions<cr>",
            { desc = "AI: Open action palette" }
        )
        vim.keymap.set(
            "v",
            "<leader>as",
            "<cmd>CodeCompanionChat Add<cr>",
            { desc = "AI: Add selection to Codex chat" }
        )

        -- Gemini Keymaps
        vim.keymap.set(
            "v",
            "<leader>ai",
            function()
                require("codecompanion").prompt("edit_selection")
            end,
            { desc = "AI: Edit selection in place (Gemini)" }
        )
        vim.keymap.set(
            "v",
            "<leader>at",
            "<cmd>CodeCompanion /tests<cr>",
            { desc = "AI: Generate tests for selection (Gemini)" }
        )
        vim.keymap.set(
            "v",
            "<leader>ae",
            "<cmd>CodeCompanion /explain<cr>",
            { desc = "AI: Explain selected code (Gemini)" }
        )
        vim.keymap.set(
            "v",
            "<leader>ap",
            ":CodeCompanion ",
            { desc = "AI: Prompt selection (Gemini)" }
        )
    end
}
