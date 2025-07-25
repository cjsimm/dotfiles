return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- Load LS when opening existing or new file
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",             --completion source
    },
    config = function()
        --required imports
        local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        --set keybinds for language server features. modify opts before each bind to describe what it does
        local opts = { noremap = true, silent = true }
        local on_attach = function(client, bufnr)
            opts.buffer = bufnr
            --display information
            opts.desc = "Go to declaration"
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            opts.desc = "Show LSP Definitions"
            vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
            opts.desc = "See available code actions"
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
            --modify
            opts.desc = "Smart rename"
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            --diagnostics
            -- show float on diagnostic jumps (default [d and ]d)
            vim.diagnostic.config({ jump = { float = true } })
            opts.desc = "Show buffer diagnostics"
            vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
            opts.desc = "Show line diagnostics"
            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

            -- set nvim to format on save using default formatter associated with lsp
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
                desc = "Format on save",
            })
        end
        --default capabilities from the completion engine that we will assign to most language servers
        local capabilities = cmp_nvim_lsp.default_capabilities()
        --diagnostic symbols to appear in the gutter
        local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
        --individual language server configurations
        lspconfig["html"].setup({
            capabilities = capabilities, --pass the completion engine capabilities in
            on_attach = on_attach,       -- pass our on-attach keybinds in,
            filetypes = { "html", "templ", "vue" },
        })
        lspconfig["cssls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })
        lspconfig["tailwindcss"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })
        lspconfig["emmet_ls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            filetypes = {
                "html",
                "typescriptreact",
                "javascriptreact",
                "css",
                "sass",
                "scss",
                "less",
            },
        })
        lspconfig["ts_ls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            init_options = {
                plugins = {
                    {
                        name = "@vue/typescript-plugin",
                        location = vim.fn.expand("$MASON/packages/vue-language-server") ..
                            "/node_modules/@vue/language-server",
                        languages = { "vue" },
                    },
                },
            },
            filetypes = {
                "typescript", "javascript", "javascriptreact", "typescriptreact", "vue"
            }
        })
        lspconfig["eslint"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })
        lspconfig["pyright"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })
        lspconfig["clangd"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })
        lspconfig["rust_analyzer"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                ["rust-analyzer"] = {
                    checkOnSave = {
                        enable = true,
                        command = "clippy"
                    }
                }
            }

        })
        lspconfig["bashls"].setup({
            capabilities = capabilities,
            on_attach = on_attach
        })
        lspconfig["docker_compose_language_service"].setup({
            capabilities = capabilities,
            on_attach = on_attach
        })
        lspconfig["dockerls"].setup({
            capabilities = capabilities,
            on_attach = on_attach
        })
        lspconfig["ansiblels"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            filetypes = { "yaml", "yml", "ansible" },
            root_dir = lspconfig.util.root_pattern("roles", "playbooks")
        })
        --specific config for lua to help with nvim config
        lspconfig["lua_ls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                Lua = {
                    -- make the language server recognize "vim" global
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        -- make language server aware of runtime files
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                    format = {
                        enable = true,
                    }
                },
            },
        })
    end
}
