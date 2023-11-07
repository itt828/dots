--
--
--

require('lspconfig')['bashls'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    single_file_support = true,
}
