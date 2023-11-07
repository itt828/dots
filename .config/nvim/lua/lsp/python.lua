require('lspconfig')['pylsp'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    autostart = true
}
