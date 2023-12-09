myHome = os.getenv('HOME')
hyper = {'shift', 'cmd', 'alt', 'ctrl'}

-- screen objects setup
-- TODO: screen ordering
screens = hs.screen.allScreens()

-- naming for laptop screen can be inconsistent (Retina or Color LCD)... if not working, check with
-- `for _, s in pairs(hs.screen.allScreens()) do print(s) end`
-- screensAll = hs.screen.allScreens()
-- screenOrder = {'Retina', 'VG27A', 'VX238'}
-- screens = {}
-- for i, screenName in ipairs(screenOrder) do
--   screens[i] = hs.screen.find(screenName)
-- end

-- hs params for configuring behavior
displayLayout = 'tarmak1'
useSecrets = false
showDate = true
showVol = true
showBatt = false
showCal = true
showBT = true

-- imports
hs.loadSpoon('Emojis')
require('alerts')
require('bluetooth')
if #displayLayout > 0 then require('tarmak') end
-- require('window_management')  -- simpler to use rectangle for this
if useSecrets then require('secrets') end

-- convenience function for printing objects
-- https://stackoverflow.com/a/27028488
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-- auto reload config
-- https://www.hammerspoon.org/go/#fancyreload
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == '.lua' then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(myHome .. '/.hammerspoon/', reloadConfig):start()
hs.alert.show('Config loaded')

-- force dismiss alerts
function dismissAlert() hs.alert.closeAll() end
hs.hotkey.bind(hyper, 'q', dismissAlert)

-- one button lock screen
-- note: you may want to use karabiner to set Function Keys > f6 to be the literal f6 for best compatibility with built in keyboard
hs.hotkey.bind({}, 'f6', function () hs.eventtap.keyStroke({'cmd', 'ctrl'}, 'Q') end)

-- toggle bluetooth power status
hs.hotkey.bind({}, 'f5', toggleBtPower)

-- compose alerts
hs.hotkey.bind({}, 'f4', function()
    if showDate then dateAlert('forever') end
    if showCal then calAlert('forever') end
    if showBatt then batteryAlert('forever') end
    if showVol then volumeAlert('forever') end
    if showBT then btAlerts('forever') end
    if #displayLayout > 0 then showLayout(alt_layouts[displayLayout], 'forever') end
end, dismissAlert)

--  markdown paste: take a string, and if it matches some pattern (e.g. ticket ID), then format it as a markdown link with the appropriate URL prefix
-- sample similar function (actual function in secrets):
-- function mdPaste()
--     local copiedText = hs.pasteboard.getContents()

--     local urlPrefix = 'https://tracking-website.com/'
--     local matchPattern = 'PROJ%a+-%d+'
--     local matchResult = string.match(copiedText, matchPattern)

--     if  matchResult ~= nil then
--         echoString = 'echo "[' .. matchResult .. '](' .. urlPrefix .. matchResult .. ')"'
--     else
--         return
--     end

--     ret, _, _, _ = hs.execute(echoString)
--     hs.eventtap.keyStrokes(ret)
-- end
if useSecrets then hs.hotkey.bind({'cmd', 'alt'}, 'v', mdPaste) end

-- emoji picker
-- source: https://aldur.pages.dev/articles/2016/12/19/hammerspoon-emojis
spoon.Emojis:bindHotkeys({toggle = {{"cmd", "alt"}, 'e'}})

-- quick app selection
-- source: https://kawamurakazushi.com/20200503-Hammerspoon-to-improve-Developer-Experience/
local apps = {
    { key = "z", app = "slack" },
    { key = "x", app = "google chrome" },
    { key = "c", app = "visual studio code" },
    { key = "v", app = "iterm" },
    { key = "b", app = "obsidian" }
  }
  
for i, object in ipairs(apps) do
    hs.hotkey.bind(hyper, object.key, function()
        hs.application.launchOrFocus(object.app)
    end)
end
