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
                adapter = "copilot",
            },
            inline = {
                adapter = "copilot",
            },
            cmd = {
                adapter = "copilot",
            },
        },
        opts = {
            log_level = "DEBUG",
        },
    },
}
