return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        -- default adapter with no token cost for all behaviours by default
        local gemini_default = {
            name = "gemini",
            model = "gemini-2.5-flash",
        }
        require("codecompanion").setup({
            strategies = {
                chat = {
                    adapter = gemini_default
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
        vim.keymap.set(
            { "n", "v" },
            "<leader>a",
            "<cmd>CodeCompanionChat Toggle<cr>",
            { desc = "Toggle a chat buffer" }
        )
        vim.keymap.set(
            { "n", "v" },
            "<C-a>",
            "<cmd>CodeCompanionActions<CR>",
            { desc = "Open the action palette" }
        )
    end
}
