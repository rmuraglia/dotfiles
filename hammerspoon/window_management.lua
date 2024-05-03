-- NOTE: basically all of this is just archival/personal reference
-- I basically just use rectangle for a lot of this now

-- lcag = {'cmd', 'alt', 'ctrl'}

-- expose/mission control replacement
-- WARN: occasionally totally locks up, so I don't really use this anymore
expose = hs.expose.new(nil, {otherSpacesStripWidth=0.35, fitWindowsMaxIterations=10})

-- sample keybind
-- hs.hotkey.bind(hyper, 'E', function() expose:toggleShow() end)

-----
-- WINDOW RESIZING/SNAPPING WITHIN A DISPLAY
-----

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

-- sample usages
-- hs.hotkey.bind({'ctrl', 'alt'}, 'left', snapWindow(33, 'left'))
-- hs.hotkey.bind({'alt', 'cmd'}, 'left', snapWindow(50, 'left'))
-- ...
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'right', snapWindow(67, 'right'))
-- hs.hotkey.bind({'ctrl', 'alt'}, 'down', snapWindow(34, 'center'))
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'up', snapWindow(100, 'center'))

-----
-- WINDOW THROWING ACROSS DISPLAYS
-----

-- https://stackoverflow.com/a/58398311
-- NOTE: hardcoded to an ordered three screen layout
-- NOTE: issues with fullscreen apps:
    -- note this won't move full screen apps (which might be because they are treated as entire spaces)
    -- can try to detect/toggle fs status with win:isFullScreen() and win:toggleFullScreen() first, but that's leaving a weird visual artifact
    -- function fsToggle() hs.eventtap.keyStroke({'cmd', 'ctrl'}, 'F') end  -- tried own manual fs toggle but still leaving the ghost image

function throwToDisplay(idx)
    return function()
      local win = hs.window.focusedWindow()
      win:moveToScreen(screens[idx], false, true)
    end
end

-- sample usage:
-- hs.hotkey.bind(hyper, '1', throwToDisplay(1))
-- hs.hotkey.bind(hyper, '2', throwToDisplay(2))
-- hs.hotkey.bind(hyper, '3', throwToDisplay(3))

function throwDiplayOver(direction)
    return function()
        local win = hs.window.focusedWindow()

        if direction == 'left' then win:moveOneScreenWest(false, true)
        elseif direction == 'right' then win:moveOneScreenEast(false, true)
        end
    end
end

-- hs.hotkey.bind(hyper, '4', throwDiplayOver('left'))
-- hs.hotkey.bind(hyper, '5', throwDiplayOver('right'))

------
-- MOVING MOUSE FOCUS ACROSS DISPLAYS
------

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
      hs.eventtap.keyStroke({}, 'ESCAPE')  -- or right click and immediately dismiss context menu
    end
end

function focusToDisplay(idx, clickType)
    return function()
      local screen = screens[idx]
      focusDisplay(screen, clickType)
    end
end

-- hs.hotkey.bind(lcag, '1', focusToDisplay(1, 'left'))
-- hs.hotkey.bind(lcag, '2', focusToDisplay(2, 'left'))
-- hs.hotkey.bind(lcag, '3', focusToDisplay(3, 'left'))

-- just moving the mouse cursor, but not transfering focus
-- combine this with opt cmd X from warpd
function warpCursor(direction)
  if direction == 'left' then
    rect = hs.mouse.getCurrentScreen():toWest():fullFrame()
  else
    rect = hs.mouse.getCurrentScreen():toEast():fullFrame()
  end
  local center = hs.geometry.rectMidPoint(rect)
  hs.mouse.absolutePosition(center)
end

-- try to set "warp spots" in a given display, like the centers of a 3x3 grid
function warpGrid(horizontal, vertical)
    local mults = {left=0.25, center=0.50, right=0.75, top=0.25, bottom=0.75}
    local rect = hs.mouse.getCurrentScreen():fullFrame()
    local warpPoint = hs.geometry.point(
        rect.x + rect.w * mults[horizontal],
        rect.y + rect.h * mults[vertical]
    )
    hs.mouse.absolutePosition(warpPoint)
end
