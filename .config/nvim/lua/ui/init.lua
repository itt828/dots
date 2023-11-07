-- colorscheme
require("catppuccin").setup({
    --flavour = 'macchiato',
    flavour = 'frappe',
    --flavour = 'latte',
    --flavour = 'mocha',
    integrations = {},
})
vim.cmd('colorscheme catppuccin')
require('lualine').setup {
    options = {
        theme = 'catppuccin'
    }
}

-- ddu
require('ui.ddu')

-- noice
--require("noice").setup({
--    lsp = {
--        ide = {
--            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
--            ["vim.lsp.util.stylize_markdown"] = true,
--            ["cmp.entry.get_documentation"] = true,
--        },
--    },
--    presets = {
--        bottom_search = true,
--        command_palette = true,
--        long_message_to_split = true,
--        inc_rename = false,
--        lsp_doc_border = false,
--    },
--})