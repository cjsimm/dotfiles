return {
    'nvim-telescope/telescope.nvim', tag = '0.1.3',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'BurntSushi/ripgrep',
        'nvim-treesitter/nvim-treesitter',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        "debugloop/telescope-undo.nvim",
        "nvim-tree/nvim-web-devicons"
    },
      config = function()
        local telescope = require("telescope")
	    local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")
        telescope.setup({
            defaults = {
                path_display = { "truncate " },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                        ["<C-j>"] = actions.move_selection_next, -- move to next result
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
        })
        --extensions
        telescope.load_extension("fzf")
        telescope.load_extension("undo")
        -- picker functions
        local function find_files()
            builtin.find_files({
                hidden = true, 
                follow = true,
                no_ignore = true,
            })
        end
        local function live_grep()
            builtin.live_grep({
                additional_args = { "--hidden", "--follow" }
            })
        end
        --keymaps
	    vim.keymap.set('n', '<leader>ff', find_files, { desc = "Telescope find files" })
        vim.keymap.set('n', '<leader>fg', live_grep, {}) --grep for all files in directory 
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {}) -- show all currently open buffers
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {}) --show all docs entries with defined vim :helptags
        vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, {}) --show every high level symbols
        vim.keymap.set('n', '<leader>fu', "<cmd>Telescope undo<cr>", {}) -- <CR> to yank additions from highlighted state, ctrl-CR to restore to state shift-CR to yank deletions
    end
}
