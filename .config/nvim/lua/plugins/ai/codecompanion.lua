return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        --Define which model to be used for each functionality
        strategies = {
            chat = {
                adapter = "gemini",
            },
            inline = {
                adapter = "gemini",
            },
            cmd = {
                adapter = "gemini",
            },
        },
        opts = {
            log_level = "DEBUG",
        },
    },
    config = function()
        require("codecompanion").setup({})
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
