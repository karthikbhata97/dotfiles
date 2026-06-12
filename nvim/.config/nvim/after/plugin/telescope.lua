local home = vim.fn.expand("$HOME")

require("telescope").setup({
    defaults = {
        sorting_strategy = "ascending",
        -- Use ripgrep for live_grep / grep_string.
        -- --ignore-file forces respecting ~/.rgignore even inside git repos,
        -- where the upward ignore-file search would otherwise stop at the repo root.
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!**/.git/*",
            "--ignore-file=" .. home .. "/.rgignore",
        },
    },
    pickers = {
        find_files = {
            -- Use fd for find_files. --ignore-file forces respecting ~/.fdignore
            -- regardless of the directory Telescope is launched from.
            find_command = {
                "fd",
                "--type=file",
                "--hidden",
                "--strip-cwd-prefix",
                "--exclude=.git",
                "--ignore-file=" .. home .. "/.fdignore",
            },
        },
        buffers = {
            initial_mode = "normal",
        },
    },
    extensions = {
        fzf = {
            fuzzy = false,                  -- substring matching only (no scattered-letter fallback)
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
})

-- Load the native fzf sorter (built via `make`). Contiguous matches rank
-- highest; prefix a query with ' for a strict exact-substring match.
require("telescope").load_extension("fzf")

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', function() builtin.buffers({sort_mru = true}) end, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader><Tab>', function() builtin.buffers({sort_mru = true, ignore_current_buffer = true}) end, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope grep word under cursor' })
