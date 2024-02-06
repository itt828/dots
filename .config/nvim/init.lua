-- TOC:
-- 1. flags
-- 2. options
-- 3. plugins
-- 4. plugin configs
-- 4.1. theme
-- 4.2. ui
-- 4.3. lsp
-- 4.4. diagnostics
-- 5. autocmds
-- 6. keymaps

local flags = {
    satysfi = true,
    theme = 'tokyonight',
    theme_config = {
        catppuccin = {
            flavour = 'frappe',
        },
        tokyonight = {
            style = 'day',
        }
    }
}


local options = {
    autoindent = true,
    backup = false,
    breakindent = true,
    clipboard = 'unnamedplus',
    cmdheight = 1,
    cursorline = true,
    expandtab = true,
    hidden = true,
    ignorecase = true,
    incsearch = true,
    mouse = 'a', -- enable mouse support
    number = true,
    relativenumber = true,
    shiftwidth = 4,
    shortmess = vim.opt.shortmess + 'c',
    smartcase = true,
    smartindent = true,
    swapfile = false,
    tabstop = 4,
    termguicolors = true,
}

for k, v in pairs(options) do
    vim.opt[k] = v
end


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.rtp:prepend(vim.env.HOME .. '/.config')

require('lazy').setup({
    defaults = { lazy = true },
    -- themes
    {
        'folke/tokyonight.nvim',
        event = 'VimEnter',
        enabled = flags.theme == 'tokyonight'
    },
    {
        'catppuccin/nvim',
        event = 'VimEnter',
        enabled = flags.theme == 'catppuccin'
    },
    -- ui
    {
        'nvim-lualine/lualine.nvim',
        event = 'VimEnter',
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        }
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        }
    },
    -- lsp
    { 'neovim/nvim-lspconfig' },
    { 'williamboman/mason.nvim' },
    {
        'ionide/Ionide-vim',
        build = 'make fsautocomplete',
        ft = { 'fsharp', 'fs', 'fsx' },
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
    },
    -- diagnostics
    {
        'folke/trouble.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
    },
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

-----------------------------------------------------------------------------
-- theme
-----------------------------------------------------------------------------

if flags.theme == 'catppuccin' then
    require('catppuccin').setup({
        flavour = flags.theme_config.catppuccin.flavour,
        integrations = {},
    })
    vim.cmd [[colorscheme catpuccin]]
    require('lualine').setup {
        options = {
            theme = 'catppuccin'
        }
    }
elseif flags.theme == 'tokyonight' then
    require('tokyonight').setup({
        style = flags.theme_config.tokyonight.style,
    })
    vim.cmd [[colorscheme tokyonight]]
    require('lualine').setup {
        options = {
            theme = 'tokyonight'
        }
    }
end

-----------------------------------------------------------------------------
-- UI
-----------------------------------------------------------------------------

require("noice").setup({
    lsp = {
        ide = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
    },
    presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
    },
})

-----------------------------------------------------------------------------
-- LSP
-----------------------------------------------------------------------------

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

local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, linehl = "", numhl = "" })
end

require("mason").setup()

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')

local servers = {
    'bashls',
    'lua-language-server',
    'rust_analyzer',
    'volar'
}

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        capabilities = capabilities,
    }
end

vim.g['fsharp#fsautocomplete_command'] = {
    'fsautocomplete',
    --    '--adaptive-lsp-server-enabled',
}

vim.g['fsharp#lsp_auto_setup'] = 0
require("ionide").setup {
    autostart = true,
    capabilities = capabilities,
    on_attach = on_attach,
    single_file_support = true,
}

require('lspconfig')['satysfi-ls'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    autostart = true
}


local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.satysfi = {
    install_info = {
        url = "https://github.com/monaqa/tree-sitter-satysfi", -- local path or git repo
        files = { "src/parser.c", "src/scanner.c" }
    },
    filetype = "satysfi", -- if filetype does not agrees with parser name
}

require 'nvim-treesitter.configs'.setup {
    ensure_installed = {
        'satysfi',
        'lua',
    },
    highlight = {
        enable = true,
    },
    -- if you use indent.scm
    indent = {
        enable = true,
    },
    -- if you use https://github.com/andymass/vim-matchup
    --matchup = {
    -- enable = true,
    --},
}
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-enable)')
vim.keymap.set('c', '<C-j>', '<Plug>(skkeleton-enable)')

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { '*.saty', '*.satyg', '*.satyh' },
    callback = function() vim.opt.filetype = 'satysfi' end
})