return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        completions = {
            lsp = { enabled = true },
        },
    },
    config = function(_, opts)
        local markdown = require("render-markdown")
        markdown.setup(opts)

        local presenting = false
        vim.keymap.set({ "n", "x" }, "<leader>mp", function()
            presenting = not presenting
            local config = vim.deepcopy(opts)
            if presenting then
                config.anti_conceal = { enabled = false }
                config.render_modes = { "n", "c", "t", "v", "V", "\22" }
                config.win_options = { concealcursor = { rendered = "nvc" } }
            end
            markdown.setup(config)
            markdown.enable()
            vim.notify("Markdown presentation: " .. (presenting and "on" or "off"))
        end, { desc = "Markdown: Toggle presentation mode" })
    end,
}
