-- vim.keymap.set('n', '<C-Space>', ':NvimTreeToggle<CR>', { noremap = true, silent = true})

local function toggle_focus()
    local api = require("nvim-tree.api")

    if vim.bo.filetype == "NvimTree" then
        api.tree.toggle()
    else
        api.tree.focus()
    end
end

-- vim.keymap.set('n', '<C-Space>', ':NvimTreeFocus<CR>')
vim.keymap.set('n', '<C-Space>', toggle_focus, { noremap = true, silent = true })
