------------
-- GENERAL/PREAMBLE
------------

-- todo:
-- emojis: https://aldur.github.io/articles/hammerspoon-emojis/
-- gcal menu bar or alert
-- slack alert (any unread): https://github.com/chriszarate/SlackNotifier.spoon
-- throw between spaces instead of displays
-- be aware of different monitor layouts (e.g. work vs home): https://gist.github.com/philc/ed70ae4e60062c2d494fae97d5da43ce#file-init-lua-L170
-- hs.window.find('Meet') can be used to identify the window with a google meet currently going. then draw border depending on microphone/camera status?
-- chrome pop out window: https://superuser.com/questions/182720/keyboard-shortcut-to-pull-google-chrome-tab-into-its-own-window#:~:text=Just%20press%20Cmd%2FCtrl%20%2B%20L%20and%20then%20Shift%20%2B%20Enter%20.
-- replace frame with fullFrame if hiding menubar?

-- move between spaces: https://stackoverflow.com/questions/46818712/using-hammerspoon-and-the-spaces-module-to-move-window-to-new-space

lcag = {'cmd', 'alt', 'ctrl'}
hyper = {'shift', 'cmd', 'alt', 'ctrl'}

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

-- myPython = '/Users/rmuraglia/anaconda3/bin/python '
myPython = '/usr/local/bin/python3 '
myHome = os.getenv('HOME')

hs.window.animationDuration = 0
dateFmt = '%a %b %d - %I:%M %p'
CONSTANTS = {
  displayTime = 5,
  strokeWidth = 5,
  batteryCrit = 10,
  batteryLow = 25,
  batteryMed = 50,
  pingCount = 1,
  pingInterval = 0.01,
  pingTimeout = 0.5,
  pingBad = 500.0,
  pingOkay = 200.0,
}

-- screen reference globals
-- naming for laptop screen can be inconsistent (Retina or Color LCD)... if not working, check with
-- `for _, s in pairs(hs.screen.allScreens()) do print(s) end`
screensAll = hs.screen.allScreens()
screenOrder = {'Retina', 'VG27A', 'VX238'}
screens = {}

for i, screenName in ipairs(screenOrder) do
  screens[i] = hs.screen.find(screenName)
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

------------
-- ALERTS
------------

-- dismiss alerts
function dismissAlert() hs.alert.closeAll() end

hs.hotkey.bind(lcag, 'Q', dismissAlert)

-- generate alert style for alerts containing a reference to a battery/power level (e.g. battery, bluetooth)
function getPowerStyle(remainingPrc, isCharging)
  local style = {}
  if not (remainingPrc == nil) then
    if remainingPrc < CONSTANTS.batteryCrit then
      style.fillColor = hs.drawing.color.hammerspoon['osx_red']
    elseif remainingPrc < CONSTANTS.batteryLow then
      style.textColor = hs.drawing.color.hammerspoon['osx_red']
    elseif remainingPrc < CONSTANTS.batteryMed then
      style.textColor = hs.drawing.color.hammerspoon['osx_yellow']
    end
  end

  if isCharging then
    style.strokeColor = hs.drawing.color.hammerspoon['osx_green']
    style.strokeWidth = CONSTANTS.strokeWidth
  end

  return style
end

-- get bluetooth info as a table
-- note: currently not working due to python and yaml issues on new computer
function getBtInfo()
  local sep = '\n'
  local btBlob = hs.execute(myPython .. myHome .. '/.hammerspoon/Spoons/check_bluetooth.py')
  local btDevices = {}
  for m in string.gmatch(btBlob, '([^' .. sep .. ']+)') do
    table.insert(btDevices, m)
  end
  if #btDevices == 0 then
    table.insert(btDevices, 'No bluetooth devices connected')
  end
  return btDevices
end

-- bluetooth device alerts
-- bt power currently doesn't work, try https://apple.stackexchange.com/questions/215256/check-the-battery-level-of-connected-bluetooth-headphones-from-the-command-line
-- https://apple.stackexchange.com/questions/328091/airpods-battery-level-with-ioreg alternate solution with plist maybe
-- https://gist.github.com/miyagawa/ed22215692e1937ab4bc
-- annoyingly doesn't seem like headphone report to the cli? it might be that the key for the headphones is different ugh
-- or this wtf https://www.hammerspoon.org/docs/hs.battery.html#privateBluetoothBatteryInfo can get name and battery from here instead of python snippet
function btAlerts(duration)
  local btDevices = getBtInfo()
  for _, btDevice in pairs(btDevices) do
    local batteryLevel = tonumber(string.match(btDevice, '%((%d+)%%%)'))
    local powStyle = getPowerStyle(batteryLevel, nil)
    for _, screen in pairs(screens) do
      hs.alert.show(btDevice, powStyle, screen, duration)
    end
  end
end

-- battery power level alert
-- TODO: should I extend this? can check based on the power source if additional display (e.g. battery -> timeRemaining vs AC Power -> timeToFullCharge)
function batteryAlert(duration)
  local isCharging = hs.battery.isCharging()
  local batteryLevel =  hs.battery.percentage()
  local powStyle = getPowerStyle(batteryLevel, isCharging)
  local chargingMark = isCharging and ' *' or ''
  for _, screen in pairs(screens) do
    hs.alert.show('Battery: ' .. batteryLevel .. '%' .. chargingMark, powStyle, screen, duration)
  end
end

-- volume alert
-- TODO: should I incorporate microphone mute status as color fill?
function volumeAlert(duration)
  local audioDevice = hs.audiodevice.defaultOutputDevice()
  local isMuted = audioDevice:muted()
  local volumeLevel = isMuted and 'MUTED' or math.ceil(audioDevice:volume()) .. '%'
  for _, screen in pairs(screens) do
    hs.alert.show('Volume: ' .. volumeLevel, screen, duration)
  end
end

-- date alert
function dateAlert(duration)
  for _, screen in pairs(screens) do
    hs.alert.show(os.date(dateFmt), screen, duration)
  end
end

-- network alert (VPN + ping)
-- https://medium.com/@robhowlett/hammerspoon-the-best-mac-software-youve-never-heard-of-40c2df6db0f8
function scorePing(object, message, seqnum, error)
  local style = {}
  if message == 'didFinish' then
    avg = tonumber(string.match(object:summary(), '/(%d+.%d+)/'))
    if avg == 0.0 then  -- no network
      style.fillColor = hs.drawing.color.hammerspoon['osx_red']
    elseif avg >= CONSTANTS.pingOkay and avg < CONSTANTS.pingBad then
      style.strokeColor = hs.drawing.color.hammerspoon['osx_yellow']
      style.strokeWidth = CONSTANTS.strokeWidth
    elseif avg >= CONSTANTS.pingBad then
      style.strokeColor = hs.drawing.color.hammerspoon['osx_red']
      style.strokeWidth = CONSTANTS.strokeWidth
    end

    for _, screen in pairs(screens) do
      hs.alert(vpnMsg, style, screen, CONSTANTS.displayTime)
    end
  end
end

function networkAlert()
  -- text based on VPN connectivity
  local vpnRetCode = os.execute('/opt/cisco/anyconnect/bin/vpn status | grep Connected')  -- true or nil
  vpnMsg = vpnRetCode and 'VPN: Connected' or 'Not connected to VPN'

  -- color alert border based on ping
  hs.network.ping.ping("8.8.8.8", CONSTANTS.pingCount, CONSTANTS.pingInterval, CONSTANTS.pingTimeout, "any", scorePing)
end

-- calendar with current day highlighted
function calAlert(duration)
  local calRaw = hs.execute('cal -3')  -- for current month +/- one month
  local calTrim = string.gsub(calRaw, '[^%d]+$', '')  -- each underscore here is actually an underscore + backspace (check with s:byte which yields 95 and 8)

  local calClean, numDigits = string.gsub(calTrim, string.char(95, 8), '')
  local idx, _ = string.find(calTrim, '_')

  local calNoFmt = hs.styledtext.new(calClean, {
    font={name='Monaco', size=27},
    color=hs.drawing.color.hammerspoon['white']
  })
  local calFmt = calNoFmt:setStyle({
    color=hs.drawing.color.hammerspoon['osx_red'],
    backgroundColor=hs.drawing.color.hammerspoon['white']
  }, idx, idx + numDigits - 1)

  for _, screen in pairs(screens) do
    hs.alert(calFmt, {atScreenEdge=1}, screen, duration)
  end
end

-- show all alerts in one keybinding
hs.hotkey.bind(lcag, 'I', function()
  dateAlert('forever')
  calAlert('forever')
  batteryAlert('forever')
  volumeAlert('forever')
  -- networkAlert()
  -- btAlerts('forever')
end,
dismissAlert)

------------
-- WINDOW MANAGEMENT
------------

-- expose/mission control replacement
expose = hs.expose.new(nil, {otherSpacesStripWidth=0.35, fitWindowsMaxIterations=10})

hs.hotkey.bind(lcag, 'E', function() expose:toggleShow() end)

-- mouse focus to display
-- vaguely inspired from https://apple.stackexchange.com/a/370794
function focusDisplay(screen, clickType)
  -- get coordinates of center of display, move mouse and click there
  local rect = screen:fullFrame()
  local center = hs.geometry.rectMidPoint(rect)
  hs.mouse.absolutePosition(center)
  local clickSpot = hs.geometry(center.x-100, center.y-100)  -- offset a little to avoid clicking on scroll bar of vsplit window
  if clickType == 'left' then
    hs.eventtap.leftClick(clickSpot)
    hs.eventtap.leftClick(clickSpot)  -- double click to override OSX insisting on laptop being primary display when app is open on more than one display
  elseif clickType == 'right' then
    hs.eventtap.rightClick(clickSpot)
    hs.eventtap.keyStroke({}, 'ESCAPE')
  end
end

function focusToDisplay(idx, clickType)
  return function()
    local screen = screens[idx]
    focusDisplay(screen, clickType)
  end
end

hs.hotkey.bind(lcag, '1', focusToDisplay(1, 'left'))
hs.hotkey.bind(lcag, '2', focusToDisplay(2, 'left'))
hs.hotkey.bind(lcag, '3', focusToDisplay(3, 'left'))

-- move focus one display over
function focusDisplayOver(direction, clickType)
  return function()
    local currScreen = hs.mouse.getCurrentScreen()  -- can also use hs.screen.mainScreen() if prefer to use focused window but that can be weird with OSX sometimes insisting on focusing laptop display for multiple windows of same app open
    local nextScreen = nil

    if direction == 'left' then nextScreen = currScreen:toWest()
    elseif direction == 'right' then nextScreen = currScreen:toEast()
    end

    if not (nextScreen == nil) then focusDisplay(nextScreen, clickType) end
  end
end

hs.hotkey.bind(lcag, '4', focusDisplayOver('left', 'left'))
hs.hotkey.bind(lcag, '5', focusDisplayOver('right', 'left'))

-- move window to display
-- https://stackoverflow.com/a/58398311
-- note this won't move full screen apps (which might be because they are treated as entire spaces)
-- can try to detect/toggle fs status with win:isFullScreen() and win:toggleFullScreen() first, but that's leaving a weird visual artifact
-- function fsToggle() hs.eventtap.keyStroke({'cmd', 'ctrl'}, 'F') end  -- tried own manual fs toggle but still leaving the ghost image

function throwToDisplay(idx)
  return function()
    local win = hs.window.focusedWindow()
    win:moveToScreen(screens[idx], false, true)
  end
end

hs.hotkey.bind(hyper, '1', throwToDisplay(1))
hs.hotkey.bind(hyper, '2', throwToDisplay(2))
hs.hotkey.bind(hyper, '3', throwToDisplay(3))

function throwDiplayOver(direction)
  return function()
    local win = hs.window.focusedWindow()

    if direction == 'left' then win:moveOneScreenWest(false, true)
    elseif direction == 'right' then win:moveOneScreenEast(false, true)
    end
  end
end

hs.hotkey.bind(hyper, '4', throwDiplayOver('left'))
hs.hotkey.bind(hyper, '5', throwDiplayOver('right'))

-- preset window snap sizes
function snapWindow(size, position)
  return function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()  -- this gives (x, y) of bottom left corner with (width, height)

    if size == 100 then
      f = hs.layout.maximized:fromUnitRect(max)
    elseif size == 50 then
      if position == 'left' then
        f = hs.layout.left50:fromUnitRect(max)
      elseif position == 'right' then
        f = hs.layout.right50:fromUnitRect(max)
      end
    else
      if position == 'left' then
        f.x = max.x
      elseif position == 'right' then
        f.x = max.x + max.w - (size/100)*max.w
      elseif position == 'center' then
        f.x = max.x + max.w/2 - (size/2/100)*max.w
      end
      f.y = max.y
      f.w = max.w * (size/100)
      f.h = max.h
    end
    win:setFrame(f)
  end
end

-- hs.hotkey.bind({'ctrl', 'alt'}, 'left', snapWindow(33, 'left'))
-- hs.hotkey.bind({'alt', 'cmd'}, 'left', snapWindow(50, 'left'))
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'left', snapWindow(67, 'left'))
-- hs.hotkey.bind({'ctrl', 'alt'}, 'right', snapWindow(33, 'right'))
-- hs.hotkey.bind({'alt', 'cmd'}, 'right', snapWindow(50, 'right'))
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'right', snapWindow(67, 'right'))
-- hs.hotkey.bind({'ctrl', 'alt'}, 'down', snapWindow(34, 'center'))
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'up', snapWindow(100, 'center'))

hs.hotkey.bind(lcag, 'H', snapWindow(33, 'left'))
hs.hotkey.bind(hyper, 'H', snapWindow(50, 'left'))
hs.hotkey.bind(hyper, 'K', snapWindow(67, 'left'))
hs.hotkey.bind(lcag, 'L', snapWindow(33, 'right'))
hs.hotkey.bind(hyper, 'L', snapWindow(50, 'right'))
hs.hotkey.bind(hyper, 'J', snapWindow(67, 'right'))
hs.hotkey.bind(lcag, 'J', snapWindow(34, 'center'))
hs.hotkey.bind(lcag, 'K', snapWindow(100, 'center'))

-- test scroll wheel
hs.hotkey.bind(lcag, 'B', function() hs.eventtap.scrollWheel({0, 10}, {}) end)

-- test emoji picker. this works but may be an older method of doing it.
-- source: https://aldur.github.io/articles/hammerspoon-emojis/
-- try using the Spoon as shown in his currrent config
-- Build the list of emojis to be displayed.
-- local choices = {}
-- for _, emoji in ipairs(hs.json.decode(io.open("emojis/emojis.json"):read())) do
--     table.insert(choices,
--         {text=emoji['name'],
--             subText=table.concat(emoji['kwds'], ", "),
--             image=hs.image.imageFromPath("emojis/" .. emoji['id'] .. ".png"),
--             chars=emoji['chars']
--         })
-- end

-- -- Focus the last used window.
-- local function focusLastFocused()
--     local wf = hs.window.filter
--     local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
--     if #lastFocused > 0 then lastFocused[1]:focus() end
-- end

-- -- Create the chooser.
-- -- On selection, copy the emoji and type it into the focused application.
-- local chooser = hs.chooser.new(function(choice)
--     if not choice then focusLastFocused(); return end
--     hs.pasteboard.setContents(choice["chars"])
--     focusLastFocused()
--     hs.eventtap.keyStrokes(hs.pasteboard.getContents())
-- end)

-- chooser:searchSubText(true)
-- chooser:choices(choices)

-- hs.hotkey.bind({"cmd", "alt"}, "E", function() chooser:show() end)

-- get spoon from https://github.com/Hammerspoon/Spoons/blob/master/Spoons/Emojis.spoon.zip
hs.loadSpoon('Emojis')

spoon.Emojis:bindHotkeys({toggle = {{"cmd", "alt"}, 'e'}})
