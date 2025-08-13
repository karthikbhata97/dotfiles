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
vim.keymap.set('n', '<leader>v',  function() vim.cmd("vsplit | wincmd l") end, { noremap = true, silent = true }) -- Vertical split
vim.keymap.set('n', '<leader>s',  function() vim.cmd("split | wincmd j") end, { noremap = true, silent = true }) -- Vertical split
vim.keymap.set('n', '<A-,>', function() vim.cmd("vertical-resize -10") end, { noremap = true, silent = true }) -- Equalize split sizes
vim.keymap.set('n', '<A-.>', function() vim.cmd("vertical-resize +10") end, { noremap = true, silent = true }) -- Equalize split sizes
vim.keymap.set('t', '<C-[>', '<C-\\><C-n>', { noremap = true, silent = true }) -- Exit terminal mode
vim.keymap.set('t', '<leader>w', function() vim.cmd("wincmd w") end, { noremap = true, silent = true }) -- Exit terminal mode


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

vim.api.nvim_create_autocmd({"VimEnter"}, {
    callback = function()
        if vim.fn.argc() == 0 then
            vim.cmd("vsplit")
            vim.cmd("terminal")
            vim.cmd("vertical-resize 80")
            DefaultTerminalJob = vim.bo.channel
            DefaultTerminalWin = vim.api.nvim_get_current_win()
            vim.cmd("wincmd l")
        end
    end
})

vim.api.nvim_create_autocmd({"WinEnter"}, {
    callback = function()
        -- If the current window is a terminal, enter insert mode
        if vim.api.nvim_get_option_value('buftype', {buf = 0}) == 'terminal' then
            vim.cmd("startinsert")
        end
    end
})

local function open_term()
    vim.cmd("split | wincmd j | terminal")
    -- vim.cmd("vertical-resize 80")
    vim.cmd("startinsert")
end

vim.keymap.set({'n', 't'}, '<leader>q', GotoPrevWindow, { noremap = true, silent = true })
vim.keymap.set({'n', 't'}, '<leader>t', open_term, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>m', vim.lsp.buf.rename, { noremap = true, silent = true })
vim.api.nvim_create_user_command('Rename', 'lua vim.lsp.buf.rename()', { desc = 'Rename symbol under cursor' })

-- allow ":" in expand('<cfile>')
vim.opt.isfname:append(':')

-- remap gf to smart behavior
vim.keymap.set('n', 'gf', function()
  local f = vim.fn.expand('<cfile>')           -- e.g. "foo/bar.rs:123"
  local name, lnum = f:match('^(.*):(%d+)')    -- try to split off :NUM
  if name and lnum then
    -- open the file…
    vim.cmd('edit +' .. lnum .. ' ' .. name)
  else
    vim.cmd('edit ' .. f)
  end
end, { silent = true })
