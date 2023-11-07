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
