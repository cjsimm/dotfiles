return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", --load plugin on an event
    dependencies = {
        "hrsh7th/cmp-buffer", --source for the completion engine's recommended text
        "hrsh7th/cmp-path", --source for recommended filesystem paths
        "hrsh7th/cmp-nvim-lsp-signature-help", -- function signature help 
        "L3MON4D3/LuaSnip", --snippet engine
        "saadparwaiz1/cmp_luasnip", --auto completion source for snippets
        "rafamadriz/friendly-snippets", --better snippets 
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        --ensures comparatibilty of friendly snippets with luasnip
        require("luasnip.loaders.from_vscode").lazy_load()
        --LuaSnip setup
        -- 
        luasnip.config.set_config({
            region_check_events = 'InsertEnter',
            delete_check_events = 'InsertLeave'
        })
        --setup for nvim cmp
        cmp.setup({
            --configure how completion menu works 
            completion = {
                completeopt = "menu,menuone,preview,noselect",
            },
            --configure interaction with luasnip
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            --key mappings for completion menu
            mapping = cmp.mapping.preset.insert({
                --scroll through completion options 
                ['<C-k>'] = cmp.mapping.select_prev_item(),
                ['<C-j>'] = cmp.mapping.select_next_item(),
                --scroll up and down through doc snippet
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                --auto complete
                ['<C-Space>'] = cmp.mapping.complete(),
                --exit completion menu
                ['<C-e>'] = cmp.mapping.abort(),
                -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                --jump between arguments when snippet selected 
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                --reverse cycling through arguments 
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" })
            }),
            --sources for autocompletion. order of sources control priority in completion
            sources = cmp.config.sources({
                { name = "nvim_lsp" }, --language server 
                { name = "nvim_lsp_signature_help" }, --function signature prompt 
                { name = "luasnip" }, --snippets
                { name = "buffer" }, -- text inside buffer
                { name = "path" }, -- system paths
            }),
        })
    end
}
