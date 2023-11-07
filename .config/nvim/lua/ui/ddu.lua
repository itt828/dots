vim.fn['ddu#custom#patch_global']({
    ui = 'ff',
    uiParams = {
        ff = {
            split = 'floating',
            floatingBorder = 'rounded',
            previewFloating = true,
            previewSplit = 'horizontal',
            previewFloatingBorder = 'rounded',
            prompt = '> ',
            startFilter = true,
            autoAction = {
                name = 'preview'
            },
        }
    },
    kindOptions = {
        file = {
            defaultAction = 'open',
        }
    },
    sources = {
        { name = 'file_rec' }
    },
    sourceOptions = {
        _ = {
            matchers = { 'matcher_fzf' },
            ignoreCase = true,
        }
    },
    filterParams = {
        matcher_fzf = {
            highlightMatched = 'Search'
        }
    }
})


vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'ddu-ff' },
    callback = function()
        vim.keymap.set('n', '<cr>', '<cmd>call ddu#ui#ff#do_action("itemAction")<cr>', { buffer = true })
        vim.keymap.set('n', 'p', '<cmd>call ddu#ui#ff#do_action("preview")<cr>', { buffer = true })
        vim.keymap.set('n', '<esc>', '<cmd>call ddu#ui#ff#do_action("quit")<cr>', { buffer = true })
        vim.keymap.set('n', 'i', '<cmd>call ddu#ui#ff#do_action("openFilterWindow")<cr>', { buffer = true })
    end
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'ddu-ff-filter' },
    callback = function()
        vim.keymap.set('i', '<cr>', '<esc><cmd>close<cr>')
        vim.keymap.set('n', '<esc>', '<cmd>call ddu#ui#ff#do_action("quit")<cr>', { buffer = true })
        vim.keymap.set('i', '<esc>', '<cmd>call ddu#ui#ff#do_action("quit")<cr>', { buffer = true })
    end
})


buf = function()
    vim.fn['ddu#start']({
        sources = {
            { name = 'buffer' }
        }
    })
end


vim.keymap.set('n', '<leader>f', '<cmd>call ddu#start({})<cr>')
vim.keymap.set('n', '<leader>bb', function() buf() end)
