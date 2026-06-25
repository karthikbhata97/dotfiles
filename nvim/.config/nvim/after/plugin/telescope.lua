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

-- jj changed-files picker: only files changed in the current working copy (@).
-- Preview shows the live `jj diff` for the highlighted file.
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local make_entry = require("telescope.make_entry")
local from_entry = require("telescope.from_entry")
local conf = require("telescope.config").values

local function jj_changed_files(opts)
    opts = opts or {}
    local root = vim.fn.systemlist({ "jj", "root" })[1]
    if vim.v.shell_error ~= 0 or not root or root == "" then
        vim.notify("Not in a jj repo", vim.log.levels.ERROR)
        return
    end
    local files = vim.fn.systemlist({ "jj", "-R", root, "diff", "-r", "@", "--name-only" })
    if vim.v.shell_error ~= 0 then
        vim.notify("jj diff failed:\n" .. table.concat(files, "\n"), vim.log.levels.ERROR)
        return
    end
    files = vim.tbl_filter(function(f) return f ~= "" end, files)
    if #files == 0 then
        vim.notify("No working-copy changes (jj @)", vim.log.levels.INFO)
        return
    end

    opts.cwd = root
    local diff_previewer = previewers.new_termopen_previewer({
        title = "JJ Diff",
        get_command = function(entry)
            return {
                "jj", "-R", root, "diff", "-r", "@", "--git", "--color=always",
                from_entry.path(entry, false),
            }
        end,
    })

    pickers.new(opts, {
        prompt_title = "JJ Changed Files (working copy @)",
        finder = finders.new_table({
            results = files,
            entry_maker = make_entry.gen_from_file(opts),
        }),
        sorter = conf.file_sorter(opts),
        previewer = diff_previewer,
    }):find()
end

vim.keymap.set('n', '<leader>gc', jj_changed_files, { desc = 'Telescope jj changed files (working copy)' })
