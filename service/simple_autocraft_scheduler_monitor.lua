local rs = peripheral.find("rsBridge");

local monitors = nil;

local function updateMonitors()
    for i = 1, #monitors do
        local monitor = monitors[i]
        monitor.setCursorBlink(false);

        local monWidth_, monHeight_ = monitor.getSize()

        local maxDigitsLen_ = 4
        local wrapping_ = 1

		-- 9999/9999
        -- 4 + 1 + 4
        local fullAmountLen_ = maxDigitsLen_*2+1

		-- 9999
        -- 4
        local failedToCraftAmountLen_ = maxDigitsLen_

		-- string.sub("minecraft:planks", 1, subDivideLen)
        local subDividelen_ = monWidth_ - (wrapping_ + failedToCraftAmountLen_ + wrapping_ + fullAmountLen_)

		local extras = {
            ["width"] = monWidth_,
            ["height"] = monHeight_,
            ["wrapping"] = wrapping_,
            ["maxDigitsLen"] = maxDigitsLen_,
            ["subDivideLen"] = subDividelen_,
            ["fullAmountLen"] = fullAmountLen_,
            ["failedToCraftAmountLen"] = failedToCraftAmountLen_
        }

		monitors[i]["extra"] = extras
    end
end

local ENTRY_CONFIG = "autocrafter_scheduler"

-- minecraft:planks 9999 9999/9999
local function wrapNum(maxDigitsLen, val)
    local maxSize = (10 ^ maxDigitsLen)-1;
    if val > maxSize then
        return maxSize;
    else
        return val;
    end
end

local ENTRY_DEFAULT_CONFIG = {
    ["enabled"] = true,
	["use_monitors"] = false,
	["schedule_delay"] = 1,
    ["entries"] = {
        { name = "minecraft:oak_planks", amount = 32 },
        { name = "minecraft:charcoal", amount = 64 }
    }
}

config.default(ENTRY_CONFIG, ENTRY_DEFAULT_CONFIG)
--config.save(ENTRY_CONFIG, ENTRY_DEFAULT_CONFIG)

local config = config.load(ENTRY_CONFIG)
local items = config.entries

if config.use_monitors then
	monitors = { peripheral.find("monitor"); }
	updateMonitors()
end

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
                    if config.enabled then
                        local craftResult = rs.craftItem(craftTask);
                        if not craftResult then
                            table.insert(failed, {
                                name = item.name,
                                currentCount = curItem.amount,
                                targetCount = item.amount,
                                triedToCraftCount = craftTask.count
                            })
                        end
                    else
                        print(textutils.serialise(craftTask))
                    end
                end
            end
        end
	if config.use_monitors then
		local failedLen = #failed
		for _, monitor in pairs(monitors) do
			monitor.clear()
			if failedLen == 0 then
				local message = "No failed autocrafting tasks";
				local cursorHorizontalPos = math.floor((monitor.extra.width/2) - (#message/2))
				local cursorVerticalPos = 1;
				monitor.setCursorPos(cursorHorizontalPos, cursorVerticalPos)
				monitor.write(message)
			else
				monitor.setCursorPos(1, 1)
				monitor.setTextColor(colors.red)
				monitor.write("Failed autocrafting tasks")
				monitor.setTextColor(colors.white)
				monitor.setCursorPos(1, 2)
				monitor.write("---------------------------------------------------------")
				for i = 1, failedLen do
					local line = 2+i
					-- writes amount/desiredAmount
					monitor.setCursorPos(monitor.extra.width-(monitor.extra.fullAmountLen), line)
					monitor.write(string.format("%s/%s", wrapNum(monitor.extra.wrapping, failed[i].currentCount), wrapNum(monitor.extra.wrapping, failed[i].targetCount)))

					-- writes how many failed to craft
					monitor.setCursorPos(monitor.extra.width-(monitor.extra.fullAmountLen + monitor.extra.wrapping + monitor.extra.failedToCraftAmountLen), line)
					monitor.write(string.format("%s", wrapNum(monitor.extra.wrapping, failed[i].triedToCraftCount)))

					-- writes the items minecraft id
					monitor.setCursorPos(1, line)
					monitor.write(string.sub(string.gmatch(string.format("%s", failed[i].name), ".-:(%S+)")(), 1, monitor.extra.subDividelen-monitor.extra.wrapping))
				end
			end
		end
	end
    sleep(config.schedule_delay);
end
