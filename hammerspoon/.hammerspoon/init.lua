local apps =
{
    F1 = "Ghostty",
    F2 = "Zed",
    F3 = "Microsoft Edge",
    F4 = "Obsidian",
    F5 = "Spotify",
    F6 = "Zotero",
    F7 = "Noteful",
}
for key, app in pairs(apps) do
    hs.hotkey.bind({"cmd", "alt"}, key, function()
        hs.application.launchOrFocus(app)
    end)
end
