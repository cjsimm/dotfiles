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
                "dockerfile",
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
                "vue",
                --data formats
                "json",
                "regex",
                "yaml",
                "toml",
                --doc formats
                "markdown",
                "markdown_inline",
                "jsdoc",
                "html",
                "css",
                -- tools/infrastructure
                "just"
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
