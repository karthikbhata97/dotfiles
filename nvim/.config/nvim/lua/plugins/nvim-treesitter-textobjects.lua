return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function()
        -- Disable builtin Go section maps (]] -> type|func) so ours win.
        -- See $VIMRUNTIME/ftplugin/go.vim
        vim.g.no_go_maps = true
    end,
    config = function()
        require("nvim-treesitter-textobjects").setup({
            move = {
                set_jumps = true,
            },
        })

        local move = require("nvim-treesitter-textobjects.move")
        vim.keymap.set({ "n", "x", "o" }, "]m", function()
            move.goto_next_start("@function.outer", "textobjects")
        end, { desc = "Next function" })
        vim.keymap.set({ "n", "x", "o" }, "[m", function()
            move.goto_previous_start("@function.outer", "textobjects")
        end, { desc = "Prev function" })
        vim.keymap.set({ "n", "x", "o" }, "]]", function()
            move.goto_next_start("@function.outer", "textobjects")
        end, { desc = "Next function" })
        vim.keymap.set({ "n", "x", "o" }, "[[", function()
            move.goto_previous_start("@function.outer", "textobjects")
        end, { desc = "Prev function" })
        vim.keymap.set({ "n", "x", "o" }, "]M", function()
            move.goto_next_end("@function.outer", "textobjects")
        end, { desc = "Next function end" })
        vim.keymap.set({ "n", "x", "o" }, "[M", function()
            move.goto_previous_end("@function.outer", "textobjects")
        end, { desc = "Prev function end" })
    end,
}
