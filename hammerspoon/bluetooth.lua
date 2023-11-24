-- dependencies: blueutil and jq

-- toggle bluetooth power status
function toggleBtPower()
    local _, _, exitCode = os.execute('/opt/homebrew/bin/blueutil -p toggle')
    if exitCode == 0 then
        local btPowerStatus, _, _, _ = hs.execute('/opt/homebrew/bin/blueutil -p')
        local powerString = tonumber(btPowerStatus) == 1 and 'on' or 'off'
        for _, screen in pairs(screens) do
            hs.alert.show('Bluetooth status succesfully toggled to ' .. powerString, screen)
        end
    end
end
-- note the use of the lua ternary: stored_value = logic_check and true_value or false_value

-- display bluetooth connected devices alert
-- note: alternate option is to parse hs.battery.privateBluetoothBatteryInfo(), but that somehow has less info than the version below
function getBtInfo()
    local btDevices = {}
    local btPowerStatus, _, _, _ = hs.execute('/opt/homebrew/bin/blueutil -p')
    if tonumber(btPowerStatus) == 0 then
        table.insert(btDevices, 'Bluetooth is not on')
    else
        local btBlob = hs.execute("system_profiler SPBluetoothDataType -detailLevel mini -json | /opt/homebrew/bin/jq '.SPBluetoothDataType[0].device_connected[] | keys[]'")
        for m in string.gmatch(btBlob, '[^\n"]+') do
            table.insert(btDevices, m)
        end
        if #btDevices == 0 then
            table.insert(btDevices, 'No bluetooth devices connected')
        end
    end
    return btDevices
end

function btAlerts(duration)
    local btDevices = getBtInfo()
    for _, btDevice in pairs(btDevices) do
        for _, screen in pairs(screens) do
            hs.alert.show(btDevice, screen, duration)
        end
    end
end