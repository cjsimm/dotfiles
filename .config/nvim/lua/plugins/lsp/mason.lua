return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim", --lets mason-sourced servers be configured with lsp-config plugin
    },
    config = function()
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")

        mason.setup({
            --ui icons
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                },
            }
        })
        --setup to pass downloaded language servers to lspconfig.
        mason_lspconfig.setup({
            ensure_installed = {
                --webdev
                "html",
                "cssls",
                "emmet_ls",
                "tailwindcss",
                --js/ts
                "ts_ls",
                "eslint",
                "vue_ls",
                --other
                "pyright",
                "lua_ls",
                "clangd",
                "rust_analyzer",
                "bashls",
                -- IAC
                "ansiblels",
                "docker_compose_language_service",
                "dockerls"
            },
            --setting to automatically servers that are configured
            automatic_installations = true,
            -- stop mason from enabling servers and let lspconfig take care of it
            automatic_enable = false,
        })
    end,
}
