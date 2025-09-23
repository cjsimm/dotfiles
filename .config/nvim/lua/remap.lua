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
-- splits
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split: Create Vertical" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split: Create Horizontal" })
-- Toggle between tabs and spaces
vim.keymap.set("n", "<leader>ts", function()
    if vim.opt.expandtab:get() then
        vim.opt.expandtab = false
        vim.opt.list = true
        vim.notify("Tabs are now ON (list mode enabled)", vim.log.levels.INFO)
    else
        vim.opt.expandtab = true
        vim.opt.list = false
        vim.notify("Spaces are now ON (list mode disabled)", vim.log.levels.INFO)
    end
end, { desc = "Toggle: Tabs/Spaces and List Mode" })
------------------------------------------------------
--- Visual Mode
------------------------------------------------------
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv") -- not working
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("x", "<leader>p", "\"_dP") -- leader p[aste] keeps the text you just pasted if you overwrote something
