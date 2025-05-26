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
                adapter = "openai",
            },
            inline = {
                adapter = "openai",
            },
            cmd = {
                adapter = "openai",
            },
        },
        opts = {
            log_level = "DEBUG",
        },
    },
}
