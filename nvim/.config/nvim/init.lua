vim.g.mapleader = ","
vim.opt.exrc = true

local prev_window = vim.api.nvim_get_current_win()
function GotoPrevWindow()
    local current_window = vim.api.nvim_get_current_win()
    if prev_window == current_window then
        local all_windows = vim.api.nvim_list_wins()
        local total_windows = #all_windows
        for i, win in ipairs(all_windows) do
            if win == current_window then
                if i == 1 then
                    prev_window = all_windows[total_windows]
                else
                    prev_window = all_windows[i - 1]
                end
            end
        end
    end

    vim.api.nvim_set_current_win(prev_window)
    prev_window = current_window
end

vim.api.nvim_create_autocmd({"WinEnter"}, {
    callback = function()
        prev_window = vim.api.nvim_get_current_win()
    end
})


require("an0ne")
require("config.lazy")
require("config.lsp")
