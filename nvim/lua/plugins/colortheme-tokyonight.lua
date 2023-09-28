return {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    lazy = false,
    priority = 1000,
    configure = function()
        vim.cmd[[ colorscheme tokyonight-storm ]]
    end
}

