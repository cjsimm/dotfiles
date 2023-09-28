return {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        -- Load the colorscheme
        vim.cmd [[ colorscheme moonfly ]]
    end
}
