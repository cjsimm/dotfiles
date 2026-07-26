return {
	"christoomey/vim-tmux-navigator",
	lazy = false,
	init = function()
		-- Herdr owns the shared Ctrl-h/j/k/l keys. Keep this plugin available as
		-- the fallback when Neovim is launched inside an older tmux session.
		vim.g.tmux_navigator_no_mappings = 1
	end,
	config = function()
		require("config.herdr_navigation").setup()
	end,
}
