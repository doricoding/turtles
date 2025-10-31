local rs = peripheral.find("rsBridge");
local monitor = peripheral.find("monitor");

monitor.setCursorBlink(false);

local monWidth, monHeight = monitor.getSize();

local maxDigitsLen = 4
local wrapping = 1

local ENTRY_CONFIG = "autocrafter_scheduler"

-- 9999/9999
-- 4 + 1 + 4
local fullAmountLen = maxDigitsLen*2+1

-- 9999
-- 4
local failedToCraftAmountLen = maxDigitsLen

-- string.sub("minecraft:planks", 1, subDivideLen)
local subDividelen = monWidth - (wrapping + failedToCraftAmountLen + wrapping + fullAmountLen)

-- minecraft:planks 9999 9999/9999

local function wrapNum(val)
    local maxSize = (10 ^ maxDigitsLen)-1;
    if val > maxSize then
        return maxSize;
    else
        return val;
    end
end

local ENTRY_DEFAULT_CONFIG = {
    {
        name = "minecraft:oak_planks",
        amount = 32
    }
}

config.save(ENTRY_DEFAULT_CONFIG, ENTRY_DEFAULT_CONFIG)

local items = config.load(ENTRY_DEFAULT_CONFIG)

while true do
    local failed = {};
    local itemsLen = #items;
    for i = 1, itemsLen do
        local item = items[i];
        local itemEntry = { name = item.name };
        local curItem = rs.getItem(itemEntry);
        if (curItem ~= nil) and (curItem.amount < item.amount) then
                if not rs.isItemCrafting(itemEntry) then
                    local craftTask = { name = item.name, count = (item.amount - curItem.amount) }
                    local craftResult = rs.craftItem(craftTask);
                    if not craftResult then
                        table.insert(failed, {
                            name = item.name,
                            currentCount = curItem.amount,
                            targetCount = item.amount,
                            triedToCraftCount = craftTask.count
                        })
                    end
                end
            end
        end
    monitor.clear()
    local failedLen = #failed
    if failedLen == 0 then
        monitor.setCursorPos(1, 1)
        monitor.write("No failed autocrafting tasks")
    else
        monitor.setCursorPos(1, 1)
        monitor.write("Failed autocrafting tasks")
        monitor.setCursorPos(1, 2)
        monitor.write("---------------------------------------------------------")
        for i = 1, failedLen do
            local line = 2+i
            monitor.setCursorPos(monWidth-(fullAmountLen), line)
            monitor.write(string.format("%s/%s", failed[i].currentCount, failed[i].targetCount))
            monitor.setCursorPos(monWidth-(fullAmountLen + wrapping + failedToCraftAmountLen), 1)
            monitor.write(string.format("%s", failed[i].triedToCraftCount))
            monitor.setCursorPos(1, line)
            monitor.write(string.sub(string.format("%s", failed[i].name), 1, subDividelen))
        end
    end
    sleep(1)
end
