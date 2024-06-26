myHome = os.getenv('HOME')
hyper = {'shift', 'cmd', 'alt', 'ctrl'}

-- find homebrew
-- necessary because the installation path changed between intel and m1 macs: https://apple.stackexchange.com/q/437618
brewPrefix, _, _, _ = hs.execute('/opt/homebrew/bin/brew --prefix || /usr/local/bin/brew --prefix')
brewPath = string.gsub(brewPrefix, '%s', '') .. '/bin/'

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
displayLayout = 'colemak-dhm'
useSecrets = true
showDate = true
showVol = true
showBatt = true
showCal = true
showBT = true
useEmojis = false

-- imports
require('alerts')
require('bluetooth')
if #displayLayout > 0 then require('tarmak') end
require('window_management')  -- simpler to use rectangle for this
if useSecrets then require('secrets') end
if useEmojis then hs.loadSpoon('Emojis') end
require('mouse')

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

if useSecrets then hs.hotkey.bind({'cmd', 'alt'}, 'v', superPaste) end

-- emoji picker
-- source: https://aldur.pages.dev/articles/2016/12/19/hammerspoon-emojis
if useEmojis then spoon.Emojis:bindHotkeys({toggle = {{"cmd", "alt"}, 'e'}}) end

-- warp cursor location to previous/next display
hs.hotkey.bind(hyper, 'l', function() warpCursor('left') end)
hs.hotkey.bind(hyper, 'r', function() warpCursor('right') end)

-- warp cursor location to numpad-coded area
hs.hotkey.bind(hyper, '1', function() warpGrid('left', 'bottom') end)
hs.hotkey.bind(hyper, '2', function() warpGrid('center', 'bottom') end)
hs.hotkey.bind(hyper, '3', function() warpGrid('right', 'bottom') end)
hs.hotkey.bind(hyper, '4', function() warpGrid('left', 'center') end)
hs.hotkey.bind(hyper, '5', function() warpGrid('center', 'center') end)
hs.hotkey.bind(hyper, '6', function() warpGrid('right', 'center') end)
hs.hotkey.bind(hyper, '7', function() warpGrid('left', 'top') end)
hs.hotkey.bind(hyper, '8', function() warpGrid('center', 'top') end)
hs.hotkey.bind(hyper, '9', function() warpGrid('right', 'top') end)

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
