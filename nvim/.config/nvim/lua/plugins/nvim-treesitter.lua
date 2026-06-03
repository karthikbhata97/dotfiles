local ts_filetypes = {
    "c",
    "lua",
    "vim",
    "query",
    "elixir",
    "heex",
    "javascript",
    "html",
    "rust",
    "cpp",
    "make",
    "just",
}

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({})

        vim.api.nvim_create_autocmd("FileType", {
            pattern = ts_filetypes,
            callback = function(args)
                pcall(vim.treesitter.start, args.buf)
            end,
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "c", "rust", "cpp", "javascript", "lua" },
            callback = function(args)
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end
}
