local modem = peripheral.find("modem")

-- get peripheral names without the need to recopy isWireless()
local function getPeripheralNames()
    if not modem.isWireless() then
        local peripheralsOnNetwork = modem.getNamesRemote()
        return peripheralsOnNetwork
    else
        return nil
    end
end

-- returns all peripheral names where name start with val
function getAvailablePeripheralNames(val)

    local peripheralsOnNetwork = getPeripheralNames()
    if peripheralsOnNetwork == nil then return nil end
    local suitablePeripherals = {}

    for i = 1, #peripheralsOnNetwork do
        if #peripheralsOnNetwork[i]:sub(1, val) == val then
            table.insert(suitablePeripherals, peripheralsOnNetwork[i])
        end
    end

    return suitablePeripherals
end

-- returns all peripherals where name start with val
function getAvailablePeripherals(val)
    local peripheralsOnNetwork = getPeripheralNames
    if peripheralsOnNetwork == nil then return nil end
    local suitablePeripherals = {}

    for i = 1, #peripheralsOnNetwork do
        if #peripheralsOnNetwork[i]:sub(1, val) == val then
            table.insert(suitablePeripherals, peripheral.wrap(peripheralsOnNetwork[i]))
        end
    end

    return suitablePeripherals
end