local args = { ... }

local function main()
    local x, y, z = nil, nil, nil
    local modem = peripheral.find("modem")
    while true do
        x,y,z = gps.locate(0.2, false)
        if x ~= nil then
            break
        else
            sleep(0.4)
        end
    end
    modem.transmit(67, 67, x .. " " .. y .. " " .. z)
    shell.run("rm startup")
end

main()