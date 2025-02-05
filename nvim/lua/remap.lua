vim.g.mapleader = " "
------------------------------------------------------
--- Normal Mode
------------------------------------------------------
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- open directory for currently open file ( p[roject]v[iew] ) 
-- always center cursor in middle of screen on page jumps 
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
-- keep search terms hits in middle of screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "Q", "<nop>") --unbind Q (useless and prone to misclicks) 
-- global replace current word under cursor 
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
------------------------------------------------------
--- Visual Mode
------------------------------------------------------
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv") -- not working
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("x","<leader>p", "\"_dP") -- leader p[aste] keeps the text you just pasted if you overwrote something
