

local function isInList(tbl, val);
	local res
	for _, v in pairs(tbl) do res = res or (val == v) end
	return res
end

local function ifnilretzero(val)
	if val == nil then return 0 else return val end
end

local function getPeripName(val)
	if type(val) == "string" then return val else return peripheral.getName(val) end
end

function getAllItemsCount(container)
	local items = container.list();
	local res = {};
	for _, v in pairs(items) do
		res[v.name] = ifnilretzero(res[v.name]) + v.count;
	end
	return res;
end

function getAllItemsSlotCounts(container)
	local items = container.list();
	local res = {};
	for k, v in pairs(items) do
		local entry = { slot = k, count = v.count };
		if res[v.name] == nil then
			res[v.name] = {entry};
		else
			table.insert(res[v.name], entry)
		end
	end
	return res;
end

function transfer(from, to, itemId, amount)
	local destination = getPeripName(to);
	local items = getAllItemsSlotCounts(from);
	local fromSlots = {};
	local destCount = amount;
	for k1, v1 in pairs(items) do
		if k1 == itemId then
			for _, v2 in pairs(v1) do
				table.insert(fromSlots, { slot = v2.slot, count = math.min(v2.count, destCount) });
				destCount = destCount - v2.count;
				if destCount < 1 then break; end
			end
			break;
		end
	end


	if #fromSlots == 0 then
		return 0;
	else
		local res = 0;
		for i=1, #fromSlots do
			res = res + from.pushItems(destination, fromSlots[i].slot, fromSlots[i].count);
		end
		return res;
	end
end


-- TODO: transfer to slot



