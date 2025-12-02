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
vim.keymap.set({'n', 't'}, '<leader>h', function() vim.cmd("wincmd h") end, { noremap = true, silent = true })
vim.keymap.set({'n', 't'}, '<leader>j', function() vim.cmd("wincmd j") end, { noremap = true, silent = true })
vim.keymap.set({'n', 't'}, '<leader>k', function() vim.cmd("wincmd k") end, { noremap = true, silent = true })
vim.keymap.set({'n', 't'}, '<leader>l', function() vim.cmd("wincmd l") end, { noremap = true, silent = true })
vim.keymap.set({'n', 't'}, '<leader>w', '<C-w>w', { noremap = true, silent = true }) -- Cycle to the next split
vim.keymap.set({'n', 't'}, '<leader>v',  function() vim.cmd("vsplit | wincmd l") end, { noremap = true, silent = true }) -- Vertical split
vim.keymap.set({'n', 't'}, '<leader>s',  function() vim.cmd("split | wincmd j") end, { noremap = true, silent = true }) -- Vertical split
vim.keymap.set({'n'}, '<A-,>', function() vim.cmd("vertical-resize -10") end, { noremap = true, silent = true }) -- Equalize split sizes
vim.keymap.set({'n'}, '<A-.>', function() vim.cmd("vertical-resize +10") end, { noremap = true, silent = true }) -- Equalize split sizes
vim.keymap.set('t', '<C-[>', '<C-\\><C-n>', { noremap = true, silent = true }) -- Exit terminal mode
vim.keymap.set('t', '<leader>w', function() vim.cmd("wincmd w") end, { noremap = true, silent = true }) -- Exit terminal mode

-- vim.keymap.set({'n', 't'}, '<leader><S-z>', function ()
--     vim.cmd("wincmd =")
-- end, { noremap = true, silent = true })
-- 
-- vim.keymap.set({'n', 't'}, '<leader>z', function ()
--     vim.cmd("wincmd |")
--     vim.cmd("wincmd _")
-- end, { noremap = true, silent = true })

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

-- Map q in terminal normal mode to switch to terminal insert mode
-- But this should not affect non-terminal normal mode
vim.keymap.set('n', 'q', function()
    if vim.api.nvim_get_option_value('buftype', {buf = 0}) == 'terminal' then
        print("Switching to terminal insert mode")
        return "i"
    else
        -- Do nothing, keep the default behavior of 'q'
        return "q"
    end
end, { noremap = true, silent = true, expr = true })

-- AI code below
-- Neovim "zoom" toggle that plays nice across windows per tabpage.
-- It uses winrestcmd() to capture/restore split sizes.
local function maximize_current_win()
  vim.cmd("wincmd |")
  vim.cmd("wincmd _")
end

function ToggleZoom()
  local curwin = vim.api.nvim_get_current_win()
  local z = vim.t._zoom  -- tabpage-scoped state

  -- If there is an active zoom in this tab
  if z and z.win and vim.api.nvim_win_is_valid(z.win) then
    if curwin == z.win then
      -- Toggling the same window: restore and clear state
      vim.cmd(z.restore)
      vim.t._zoom = nil
      return
    else
      -- Another window is currently zoomed: restore it first
      vim.cmd(z.restore)
      vim.t._zoom = nil
      -- then proceed to zoom the current one
    end
  end

  -- Capture current split sizes before maximizing
  local restore = vim.fn.winrestcmd()
  maximize_current_win()
  vim.t._zoom = { win = curwin, restore = restore }
end

vim.keymap.set({"n", "t"}, "<leader>z", ToggleZoom, { desc = "Toggle zoom (maximize/restore) window" })


vim.api.nvim_create_autocmd("FileType", {
    pattern = {"c", "rust", "cpp", "python"},
    callback = function()
        vim.cmd('highlight ColorColumn guibg=#fa9d9d')
        vim.opt.colorcolumn = "80"
    end
})

vim.keymap.set('n', 'gF', '<C-w>gf', { noremap = true, silent = true })
