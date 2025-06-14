return {
    "marko-cerovac/material.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("material").setup({
            disable = {
                background = true,
                term_colors = true
            },
            plugins = {
                "nvim-web-devicons",
                "nvim-cmp",
                "telescope"
            },
            lualine_style = 'default'
        })
        vim.cmd([[ colorscheme material]])
    end
}
