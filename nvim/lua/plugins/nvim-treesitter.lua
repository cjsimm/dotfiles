return {
	'nvim-treesitter/nvim-treesitter',
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup {
			ensure_installed = {
				-- treesitter required
				"c",
                "cpp",
				"vim",
				"vimdoc",
				"lua",
				"query",
				-- programming languages
				"bash",
				"javascript",
				"typescript",
				"tsx",
				"python",
				"rust",
				"glsl",
				"hlsl",
				"terraform",
				--data formats
				"json",
				"regex",
				"yaml",
				--doc formats
				"markdown",
				"jsdoc",
				"html",
				"css"
			},
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true
			}
		}
	end
}
