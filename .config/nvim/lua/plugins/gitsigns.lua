return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        current_line_blame = false,
        on_attach = function(bufnr)
            local gitsigns = require("gitsigns")

            local function map(mode, lhs, rhs, desc, options)
                options = vim.tbl_extend("force", { buffer = bufnr, desc = desc }, options or {})
                vim.keymap.set(mode, lhs, rhs, options)
            end

            map("n", "]c", function()
                if vim.wo.diff then
                    return "]c"
                end
                vim.schedule(gitsigns.next_hunk)
                return "<Ignore>"
            end, "Git: Next hunk", { expr = true })

            map("n", "[c", function()
                if vim.wo.diff then
                    return "[c"
                end
                vim.schedule(gitsigns.prev_hunk)
                return "<Ignore>"
            end, "Git: Previous hunk", { expr = true })

            map("n", "<leader>gs", gitsigns.stage_hunk, "Git: Stage hunk")
            map("n", "<leader>gr", gitsigns.reset_hunk, "Git: Reset hunk")
            map("n", "<leader>gp", gitsigns.preview_hunk, "Git: Preview hunk")
            map("n", "<leader>gb", gitsigns.blame_line, "Git: Blame line")
            map("n", "<leader>gB", function()
                gitsigns.blame_line({ full = true })
            end, "Git: Full blame line")
            map("n", "<leader>gd", gitsigns.diffthis, "Git: Diff file")
        end,
    },
}
