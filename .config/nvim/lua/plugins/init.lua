require('plugins.setup')

require('lazy').setup({
    defaults = { lazy = false },
    -- themes
    { 'folke/tokyonight.nvim' },
    { 'catppuccin/nvim' },
    -- ui
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        }
    },
    {
        'Shougo/ddu.vim',
        dependencies = {
            'vim-denops/denops.vim',
            'Shougo/ddu-ui-ff',
            'Shougo/ddu-source-file',
            'Shougo/ddu-source-register',
            'Shougo/ddu-source-file_rec',
            'shun/ddu-source-buffer',
            'Shougo/ddu-kind-file',
            'Shougo/ddu-filter-matcher_substring',
            'Shougo/ddu-filter-matcher_substring',
            'yuki-yano/ddu-filter-fzf',
        }
    },
    -- lsp
    {
        'neovim/nvim-lspconfig',
        config = function()
            local signs = { Error = "", Warn = "", Hint = "", Info = "" }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, linehl = "", numhl = "" })
            end
        end
    },
    { 'williamboman/mason.nvim' },
    {
        'ionide/Ionide-vim',
        build = 'make fsautocomplete',
        ft = { 'fsharp', 'fs', 'fsx' },
    },
    -- diagnostics
    {
        'folke/trouble.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require("trouble").setup {}
            vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>",
                { silent = true, noremap = true }
            )
            vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
                { silent = true, noremap = true }
            )
            vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",
                { silent = true, noremap = true }
            )
            vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>",
                { silent = true, noremap = true }
            )
            vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
                { silent = true, noremap = true }
            )
            vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>",
                { silent = true, noremap = true }
            )
        end
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/vim-vsnip',
            'hrsh7th/cmp-vsnip',
        },
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "vsnip" },
                }, {
                    { name = 'buffer' },
                })
            })

            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
                }, {
                    { name = 'buffer' },
                })
            })
            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end,
    },
    -- fzf
    --{ 'nvim-telescope/telescope.nvim',
    --        config = function()
    --            local actions = require('telescope.actions')
    --            local trouble = require('trouble.providers.telescope')
    --            require('telescope').setup({
    --                defaults = {
    --                    mappings = {
    --                        i = { ["<c-t>"] = trouble.open_with_trouble },
    --                        n = { ["<c-t>"] = trouble.open_with_trouble },
    --                    },
    --                }
    --            })
    --        end,
    --  dependencies = {
    --     'nvim-lua/plenary.nvim'
    --}
    --},
    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate",
    },
    {
        'vim-skk/skkeleton',
        config = function()
            vim.fn["skkeleton#config"] {
                globalJisyo = '~/.skk/SKK-JISYO.L',
                eggLikeNewline = true,
            }
            vim.keymap.set("i", "<C-j>", "<Plug>(skkeleton-enable)")

        end,
        dependencies = {
            'vim-denops/denops.vim'
        },
    },
})