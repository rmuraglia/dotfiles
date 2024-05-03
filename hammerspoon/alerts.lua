-- alert params
hs.window.animationDuration = 0
dateFmt = '%a %b %d %Y - %I:%M %p'
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

-- date alert
function dateAlert(duration)
    for _, screen in pairs(screens) do
        hs.alert.show(os.date(dateFmt), screen, duration)
    end
end

-- volume alert
function volumeAlert(duration)
    local audioDevice = hs.audiodevice.defaultOutputDevice()
    local isMuted = audioDevice:muted()
    local volumeLevel = isMuted and 'MUTED' or math.ceil(audioDevice:volume()) .. '%'
    for _, screen in pairs(screens) do
        hs.alert.show('Volume: ' .. volumeLevel, screen, duration)
    end
end

-- battery power level
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

function batteryAlert(duration)
    local isCharging = hs.battery.isCharging()
    local batteryLevel =  hs.battery.percentage()
    local powStyle = getPowerStyle(batteryLevel, isCharging)
    local chargingMark = isCharging and ' *' or ''
    for _, screen in pairs(screens) do
        hs.alert.show('Battery: ' .. batteryLevel .. '%' .. chargingMark, powStyle, screen, duration)
    end
end

-- calendar with current day highlighted
-- note: a mac update apparently broke this.
-- I previously leveraged the fact that the calendar's highlight was parsed in hs as surrounded by underscores
-- this is no longer the case, so the current day highlighting is broken for now
function calAlert(duration)
    local calRaw = hs.execute('cal -3')  -- for current month +/- one month
    local calTrim = string.gsub(calRaw, '[^%d]+$', '')  -- each underscore here is actually an underscore + backspace (check with s:byte which yields 95 and 8)

    local calClean, numDigits = string.gsub(calTrim, string.char(95, 8), '')
    local idx, _ = string.find(calTrim, '_')  -- find index of current (underscored) day

    local calNoFmt = hs.styledtext.new('\n' .. calClean, {  -- add a newline in the beginning to compensate for the notches on new macbooks
        font={name='Monaco', size=27},
        color=hs.drawing.color.hammerspoon['white']
    })  -- make it monospace

    -- local calFmt = calNoFmt:setStyle({
    --     color=hs.drawing.color.hammerspoon['osx_red'],
    --     backgroundColor=hs.drawing.color.hammerspoon['white']
    -- }, idx + 1, idx + numDigits)  -- highlight the current day

    for _, screen in pairs(screens) do
        -- hs.alert(calFmt, {atScreenEdge=1}, screen, duration)
        hs.alert(calNoFmt, {atScreenEdge=1}, screen, duration)
    end
end

-- network alert (VPN + ping)
-- source: https://medium.com/@robhowlett/hammerspoon-the-best-mac-software-youve-never-heard-of-40c2df6db0f8
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
