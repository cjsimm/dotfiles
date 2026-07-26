return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        'nvim-treesitter/nvim-treesitter',
    },
    config = function()
        local codecompanion_herdr = require("config.codecompanion_herdr")

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
