return {
    "zbirenbaum/copilot.lua",
    lazy = true, -- Don't load on startup
    cmd = {}, -- Don't load on any command (we'll manually trigger it)
    config = function()
        require("copilot").setup({
            panel = { enabled = false },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = "<Tab>",
                    accept_word = false,
                    accept_line = false,
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            server = {
                type = "nodejs",
            },
            copilot_node_command = "node",
        })
    end,
    init = function()
        local copilot_loaded = false

        vim.api.nvim_create_user_command("MyCopilot", function(opts)
            local arg = opts.args:lower()

            if arg == "on" then
                if copilot_loaded then
                    -- Already loaded, just re-enable
                    require("copilot.command").enable()
                    vim.notify("Copilot enabled", vim.log.levels.INFO)
                else
                    -- First time: load the plugin
                    require("lazy").load({ plugins = { "copilot.lua" } })
                    copilot_loaded = true
                    vim.notify("Copilot started", vim.log.levels.INFO)
                end

            elseif arg == "off" then
                if not copilot_loaded then
                    vim.notify("Copilot is not running", vim.log.levels.INFO)
                    return
                end

                -- Use copilot.lua's built-in disable which:
                -- 1. Sets is_disabled = true
                -- 2. Clears all autocmds
                -- 3. Stops the LSP client (frees RAM)
                -- 4. Tears down panel and suggestion modules
                require("copilot.command").disable()
                vim.notify("Copilot stopped", vim.log.levels.INFO)

            elseif arg == "status" then
                if not copilot_loaded then
                    vim.notify("Copilot: not loaded", vim.log.levels.INFO)
                else
                    local clients = vim.lsp.get_clients({ name = "copilot" })
                    if #clients > 0 then
                        vim.notify("Copilot: running (LSP client id: " .. clients[1].id .. ")", vim.log.levels.INFO)
                    else
                        vim.notify("Copilot: loaded but LSP stopped", vim.log.levels.INFO)
                    end
                end
            else
                vim.notify("Usage: :MyCopilot on | off | status", vim.log.levels.WARN)
            end
        end, {
            nargs = 1,
            complete = function()
                return { "on", "off", "status" }
            end,
            desc = "Enable or disable Copilot",
        })
    end,
}
