return {
    'nvim-telescope/telescope.nvim', tag = '0.1.3',
      dependencies = { 'nvim-lua/plenary.nvim', 'BurntSushi/ripgrep' },
      config = function()
	      local builtin = require("telescope.builtin")
	      local keymap = vim.keymap
	      keymap.set('n', '<leader>ff', builtin.find_files, {})
	      keymap.set('n', '<leader>fs', function()
		      builtin.grep_string({ search = vim.fn.input(" grep > ")});
	      end)
      end
}
