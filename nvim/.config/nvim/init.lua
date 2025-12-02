vim.g.mapleader = ","
vim.opt.exrc = true

local prev_window = nil

function GotoPrevWindow()
    local curr_window = vim.api.nvim_get_current_win()
    if prev_window and vim.api.nvim_win_is_valid(prev_window) and prev_window ~= curr_window then
        vim.api.nvim_set_current_win(prev_window)
    else
        vim.cmd('wincmd w')
    end
end

vim.api.nvim_create_autocmd("WinLeave", {
    callback = function()
        prev_window = vim.api.nvim_get_current_win()
    end
})


require("an0ne")
require("config.lazy")
require("config.lsp")
