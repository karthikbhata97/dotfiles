-- App launch / switch shortcuts (cmd+alt+Fn) --------------------------------
-- Single source of truth for which app each Fn key maps to.
local apps = {
    F1 = "Ghostty",
    F2 = "Zed",
    F3 = "Microsoft Edge",
    F4 = "Obsidian",
    F5 = "Spotify",
    F6 = "Zotero",
    F7 = "Noteful",
}
for key, app in pairs(apps) do
    hs.hotkey.bind({ "cmd", "alt" }, key, function()
        hs.application.launchOrFocus(app)
    end)
end

-- Caps Lock layer (no-kanata only) -----------------------------------------
-- When kanata is NOT installed, the `hammerspoon-nokanata` just target drops
-- a `capslock-layer.lua` next to this file and remaps Caps -> F18 via hidutil.
-- When kanata IS installed it provides that layer itself, so the module is
-- absent and this require is a no-op. pcall keeps a missing module silent.
pcall(require, "capslock-layer")
