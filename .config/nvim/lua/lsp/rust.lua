require('lspconfig')['rust_analyzer'].setup {
    autostart = true,
    capabilities = capabilities,
    on_attach = on_attach,
}
