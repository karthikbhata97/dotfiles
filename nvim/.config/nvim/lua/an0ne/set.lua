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
