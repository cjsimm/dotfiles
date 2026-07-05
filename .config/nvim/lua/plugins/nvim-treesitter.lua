local languages = {
    { parser = "c" },
    { parser = "cpp" },
    { parser = "vim" },
    { parser = "vimdoc" },
    { parser = "lua" },
    { parser = "query" },
    { parser = "dockerfile" },
    { parser = "bash",           aliases = { "sh" } },
    { parser = "javascript" },
    { parser = "typescript" },
    { parser = "tsx" },
    { parser = "python" },
    { parser = "rust" },
    { parser = "glsl" },
    { parser = "hlsl" },
    { parser = "terraform" },
    { parser = "vue" },
    { parser = "json" },
    { parser = "regex" },
    { parser = "yaml" },
    { parser = "toml" },
    { parser = "markdown" },
    { parser = "markdown_inline" },
    { parser = "jsdoc" },
    { parser = "html" },
    { parser = "css" },
    { parser = "just" },
}

local function append_unique(list, value)
    if not vim.list_contains(list, value) then
        list[#list + 1] = value
    end
end

return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")
        ts.setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        local parsers = {}
        local filetypes = {}

        for _, spec in ipairs(languages) do
            parsers[#parsers + 1] = spec.parser

            if spec.aliases then
                vim.treesitter.language.register(spec.parser, spec.aliases)
            end

            for _, filetype in ipairs(vim.treesitter.language.get_filetypes(spec.parser)) do
                append_unique(filetypes, filetype)
            end
        end

        local installed = ts.get_installed("parsers")
        local missing = vim.tbl_filter(function(lang)
            return not vim.list_contains(installed, lang)
        end, parsers)

        if #missing > 0 then
            ts.install(missing)
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = filetypes,
            callback = function(args)
                pcall(vim.treesitter.start, args.buf)
            end,
        })
    end,
}
