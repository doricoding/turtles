local modem = peripheral.find("modem");

local container = peripheral.wrap("functionalstorage:oak_1_0");
local machinePrefix = "thermal:machine_pulverizer";

local machineNames = peripheral.getPeripheralNamesStartingWith(machinePrefix);

local machinesLen = #machineNames;

while true do
    local items = container.list();
    if #items ~= 0 then
        local count = items[1].count
        local each = count / machinesLen
        local extra = (each - math.floor(each)) * machinesLen
        local actualEach = math.floor(each)
        local extra2 = extra
        for i = 1, machinesLen do
            if extra2 > 0 then
                container.pushItems(machineNames[i], 1, actualEach+1)
                extra2 = extra2-1
            else
                container.pushItems(machineNames[i], 1, actualEach)
            end
        end
    end
    sleep(0.05)
end
