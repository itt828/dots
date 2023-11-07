require('lspconfig')['volar'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    autostart = true,
    filetype = {'typescript','javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json'}

}

