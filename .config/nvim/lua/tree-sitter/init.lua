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
