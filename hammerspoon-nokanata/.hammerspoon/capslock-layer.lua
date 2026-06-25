-- Caps Lock layer ----------------------------------------------------------
-- Loaded by hammerspoon/.hammerspoon/init.lua (via `require "capslock-layer"`)
-- only when this file is present, which the `hammerspoon-nokanata` just target
-- installs. Caps Lock is remapped to F18 by hidutil (see files/hammerspoon
-- LaunchAgent), so this never needs a kernel driver. Holding Caps activates a
-- vim-style nav layer + the app launches (mirroring the old kanata `arrows`
-- layer). A plain tap of Caps does nothing.

-- nav keys: held Caps + key -> motion. Current modifiers (shift/cmd/...) are
-- preserved so Caps+shift+j selects downward, etc.
local nav = {
    h = "left", j = "down", k = "up", l = "right",
    f = "pagedown", b = "pageup",
}
-- app keys: held Caps + key -> launch/focus the app directly.
local layerApps = {
    q = "Ghostty", w = "Zed", e = "Google Chrome", r = "Obsidian", t = "Spotify",
    z = "Zotero", x = "Noteful",
}

-- Resolve to keycodes once.
local f18 = hs.keycodes.map["f18"]
local navByCode = {}
for from, to in pairs(nav) do navByCode[hs.keycodes.map[from]] = to end
local appByCode = {}
for from, app in pairs(layerApps) do appByCode[hs.keycodes.map[from]] = app end

local capsHeld = false
local eventTypes = hs.eventtap.event.types

local capsLayer = hs.eventtap.new({ eventTypes.keyDown, eventTypes.keyUp }, function(e)
    local code = e:getKeyCode()

    -- The Caps key (now F18): track hold state, never let it reach apps.
    if code == f18 then
        capsHeld = (e:getType() == eventTypes.keyDown)
        return true
    end

    if not capsHeld then return false end

    local isNav = navByCode[code]
    local isApp = appByCode[code]
    if not isNav and not isApp then return false end -- pass other keys through

    -- Swallow the key-up of layer keys so apps never see a stray release.
    if e:getType() ~= eventTypes.keyDown then return true end

    if isNav then
        local flags = e:getFlags()
        hs.eventtap.event.newKeyEvent(flags, isNav, true):post()
        hs.eventtap.event.newKeyEvent(flags, isNav, false):post()
    else
        hs.application.launchOrFocus(isApp)
    end
    return true
end)
capsLayer:start()

-- Keep the tap alive ------------------------------------------------------
-- macOS silently disables eventtaps if a callback is slow, under load, or
-- across sleep/wake & screen-lock. Without this, the Caps layer "randomly"
-- stops working until a manual reload. Re-enable it whenever that happens.
local function ensureTapRunning()
    if not capsLayer:isEnabled() then
        capsHeld = false -- drop any stale held state from before the drop
        capsLayer:start()
    end
end

-- 1) Poll: cheap safety net for taps the OS times out under load.
capsWatchdog = hs.timer.doEvery(5, ensureTapRunning)

-- 2) React immediately on the events most likely to kill the tap.
capsCaffeinate = hs.caffeinate.watcher.new(function(event)
    local e = hs.caffeinate.watcher
    if event == e.systemDidWake
        or event == e.screensDidWake
        or event == e.screensDidUnlock
        or event == e.sessionDidBecomeActive then
        ensureTapRunning()
    end
end)
capsCaffeinate:start()

local hyper = {"ctrl", "cmd"}

local function moveWindow(x, w)
  local win = hs.window.focusedWindow()
  if not win then return end

  local screen = win:screen()
  local frame = screen:frame()

  win:setFrame({
    x = frame.x + frame.w * x,
    y = frame.y,
    w = frame.w * w,
    h = frame.h
  })
end

hs.hotkey.bind(hyper, "left", function()
  moveWindow(0, 1 / 2)
end)

hs.hotkey.bind(hyper, "right", function()
  moveWindow(1 / 2, 1 / 2)
end)

hs.hotkey.bind(hyper, "D", function()
  moveWindow(0, 1 / 3)
end)

hs.hotkey.bind(hyper, "G", function()
  moveWindow(2 / 3, 1 / 3)
end)

hs.hotkey.bind(hyper, "E", function()
  moveWindow(0, 2 / 3)
end)

hs.hotkey.bind(hyper, "T", function()
  moveWindow(1 / 3, 2 / 3)
end)
