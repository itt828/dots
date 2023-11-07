
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.swapfile = false
vim.opt.encoding = "utf-8"
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.cmdheight = 2
vim.opt.autoindent = true
--vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.shortmess:append("c")
vim.opt.clipboard = 'unnamedplus'

vim.cmd('autocmd BufRead,BufNewFile *.saty set filetype=satysfi')
vim.cmd('autocmd BufRead,BufNewFile *.satyg set filetype=satysfi')
vim.cmd('autocmd BufRead,BufNewFile *.satyh set filetype=satysfi')