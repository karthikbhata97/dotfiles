require("telescope").setup({
    pickers = {
        buffers = {
            initial_mode = "normal",
        },
        defaults = {
            sorting_strategy = "ascending",
        }
    }
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', function() builtin.buffers({sort_mru = true}) end, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader><Tab>', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope grep word under cursor' })

