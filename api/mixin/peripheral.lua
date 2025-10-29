local modem = nil

-- get peripheral names without the need to recopy isWireless()
local function getPeripheralNames()
    if modem == nil then
        modem = peripheral.find("modem")
    end
    if not modem.isWireless() then
        local peripheralsOnNetwork = modem.getNamesRemote()
        return peripheralsOnNetwork
    else
        return nil
    end
end

-- returns all peripheral names where name start with val
function peripheral.getPeripheralNamesStartingWith(val)

    local peripheralsOnNetwork = getPeripheralNames()
    if peripheralsOnNetwork == nil then return nil end
    local suitablePeripherals = {}

    for i = 1, #peripheralsOnNetwork do
        if string.sub(peripheralsOnNetwork[i], 1, #val) == val then
            table.insert(suitablePeripherals, peripheralsOnNetwork[i])
        end
    end

    return suitablePeripherals
end

-- returns all peripherals where name start with val
function peripheral.getPeripheralsStartingWith(val)
    local peripheralsOnNetwork = getPeripheralNames()
    if peripheralsOnNetwork == nil then return nil end
    local suitablePeripherals = {}

    for i = 1, #peripheralsOnNetwork do
        if string.sub(peripheralsOnNetwork[i], 1, #val) == val then
            table.insert(suitablePeripherals, peripheral.wrap(peripheralsOnNetwork[i]))
        end
    end

    return suitablePeripherals
end