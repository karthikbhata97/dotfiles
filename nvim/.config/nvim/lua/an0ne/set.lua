vim.g.mapleader = ","

vim.opt.tabstop = 4       -- A tab appears as 4 spaces
vim.opt.softtabstop = 4   -- Tab key inserts 4 spaces
vim.opt.shiftwidth = 4    -- Indentation uses 4 spaces
vim.opt.expandtab = true  -- Converts tabs to spaces

vim.keymap.set('n', '<leader><Space>', ':noh<CR>')
vim.keymap.set('n', 'Y', 'yy')

vim.opt.scrolloff = 8
vim.opt.nu = true
vim.opt.relativenumber = true

vim.keymap.set("x", "<C-j>", ":m '>+1<cr>gv=gv", { noremap = true, silent = true })
vim.keymap.set("x", "<C-k>", ":m '<-2<cr>gv=gv", { noremap = true, silent = true })

vim.keymap.set("x", "p", '"_dP', { noremap = true, silent = true })

vim.opt.ignorecase = true

-- Map leader shortcuts for split navigation
vim.keymap.set('n', '<leader>h', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>j', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>k', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>l', '<C-w>l', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>w', '<C-w>w', { noremap = true, silent = true }) -- Cycle to the next split

vim.keymap.set('n', '<leader><S-z>', function ()
    vim.cmd("wincmd =")
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>z', function ()
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>x', ':cclose<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>r', ':cn<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader><S-r>', ':cp<CR>', { noremap = true, silent = true })

-- map <leader>c and <leader>C to toggle between Copilot enable and Copilot disable
vim.keymap.set('n', '<leader><S-c>', function ()
    vim.cmd('Copilot disable')
    vim.cmd('echo \'Copilot disabled\'')
end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>c', function ()
    vim.cmd('Copilot enable')
    vim.cmd('echo \'Copilot enable\'')
end, { noremap = true, silent = true })
