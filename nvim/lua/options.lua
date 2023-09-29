--------------------------------------------------
-- Line Numbering
--------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
--------------------------------------------------
-- Space/Tab and Indentation 
--------------------------------------------------
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
--------------------------------------------------
-- Search
--------------------------------------------------
vim.opt.hlsearch = false  -- sets whether all search matches are highlighted 
vim.opt.incsearch = true
vim.opt.ignorecase = true --ignore case by default in search
vim.opt.smartcase = true -- mixed case will assume case sensitive search
--------------------------------------------------
-- Colors and Style
--------------------------------------------------
vim.opt.termguicolors = true -- better coloring
vim.opt.background = "dark" --choose dark theme over light by default
-- vim.opt.colorcolumn = "80" -- add column to encourage line limits 
vim.opt.scrolloff = 8 -- offset page moving up and down by 8 lines
vim.opt.updatetime = 50
vim.opt.signcolumn = "yes" -- always show gutter for consistency
