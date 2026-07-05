return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        local capabilities = cmp_nvim_lsp.default_capabilities()

        local function buf_map(bufnr, mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, {
                buffer = bufnr,
                noremap = true,
                silent = true,
                desc = desc,
            })
        end

        local function on_attach(_, bufnr)
            buf_map(bufnr, "n", "gD", vim.lsp.buf.declaration, "Go to declaration")
            buf_map(bufnr, "n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Show LSP definitions")
            buf_map(bufnr, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code actions")
            buf_map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
            buf_map(bufnr, "n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Buffer diagnostics")
            buf_map(bufnr, "n", "<leader>d", vim.diagnostic.open_float, "Line diagnostics")

            vim.diagnostic.config({ jump = { float = true } })

            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
                desc = "Format on save",
            })
        end

        local function enable(name, config)
            vim.lsp.config(name, vim.tbl_deep_extend("force", {
                capabilities = capabilities,
                on_attach = on_attach,
            }, config or {}))
            vim.lsp.enable(name)
        end

        local function ansible_root(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local found = vim.fs.find({ "roles", "playbooks", ".git" }, {
                path = fname,
                upward = true,
            })

            if #found > 0 then
                on_dir(vim.fs.dirname(found[1]))
            end
        end

        enable("html", {
            filetypes = { "html", "templ", "vue" },
        })

        enable("cssls")
        enable("tailwindcss")

        enable("emmet_ls", {
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

        enable("ts_ls", {
            init_options = {
                plugins = {
                    {
                        name = "@vue/typescript-plugin",
                        location = vim.fn.expand("$MASON/packages/vue-language-server")
                            .. "/node_modules/@vue/language-server",
                        languages = { "vue" },
                    },
                },
            },
            filetypes = {
                "typescript",
                "javascript",
                "javascriptreact",
                "typescriptreact",
                "vue",
            },
        })

        enable("eslint")
        enable("pyright")
        enable("clangd")

        enable("rust_analyzer", {
            settings = {
                ["rust-analyzer"] = {
                    checkOnSave = {
                        enable = true,
                        command = "clippy",
                    },
                },
            },
        })

        enable("bashls")
        enable("docker_compose_language_service")
        enable("dockerls")

        enable("ansiblels", {
            filetypes = { "yaml", "yml", "ansible" },
            root_dir = ansible_root,
        })

        enable("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                    format = {
                        enable = true,
                    },
                },
            },
        })
    end,
}
