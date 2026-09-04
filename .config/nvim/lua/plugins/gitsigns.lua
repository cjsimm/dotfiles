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
            local diff_windows = {}

            local function map(mode, lhs, rhs, desc, options)
                options = vim.tbl_extend("force", { buffer = bufnr, desc = desc }, options or {})
                vim.keymap.set(mode, lhs, rhs, options)
            end

            local function choose_comparison_base()
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")

                require("telescope.builtin").git_branches({
                    prompt_title = "Git comparison base",
                    show_remote_tracking_branches = true,
                    attach_mappings = function(prompt_bufnr)
                        actions.select_default:replace(function()
                            local selection = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)

                            if selection then
                                gitsigns.change_base(selection.value, true)
                                vim.notify("Git comparison base: " .. selection.value)
                            end
                        end)
                        return true
                    end,
                })
            end

            local function toggle_file_diff()
                local closed_diff = false

                for _, win in ipairs(diff_windows) do
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                        closed_diff = true
                    end
                end

                diff_windows = {}
                if closed_diff then
                    return
                end

                local source_win = vim.api.nvim_get_current_win()
                local existing_windows = {}
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    existing_windows[win] = true
                end

                gitsigns.diffthis(nil, nil, function(err)
                    if err then
                        vim.notify(err, vim.log.levels.ERROR)
                        return
                    end

                    if not vim.api.nvim_win_is_valid(source_win) then
                        return
                    end

                    local tabpage = vim.api.nvim_win_get_tabpage(source_win)
                    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
                        if not existing_windows[win] and vim.wo[win].diff then
                            table.insert(diff_windows, win)
                        end
                    end
                end)
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
            map("n", "<leader>gd", toggle_file_diff, "Git: Toggle file diff")
            map("n", "<leader>gc", choose_comparison_base, "Git: Choose comparison base")
            map("n", "<leader>g0", function()
                gitsigns.reset_base(true)
                vim.notify("Git comparison base reset")
            end, "Git: Reset comparison base")
        end,
    },
}
