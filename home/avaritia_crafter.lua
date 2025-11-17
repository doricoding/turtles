local args = { ... }

local crafter = peripheral.wrap("top")
local rs = peripheral.wrap("back")
local tempStorage = peripheral.wrap("right")

local tmp = peripheral.getName(tempStorage)

local STACK_SIZE = 64

local function ifnilretzero(val)
	if val == nil then return 0 else return val end
end

local ENTRY_CONFIG = "avaritia_crafter"

local curRecipe = "avaritia:crystal_matrix_ingot"
local DEFAULT_CONFIG = {
	["recipes"] = {
		["avaritia:diamond_lattice"] = {
			[1] = "minecraft:diamond",
			[3] = "minecraft:diamond",
			[5] = "minecraft:netherite_scrap",
			[7] = "minecraft:diamond",
			[9] = "minecraft:diamond"
		},
		["avaritia:cosmic_meatballs"] = {
			[1] = "minecraft:porkchop",
			[2] = "minecraft:beef",
			[3] = "minecraft:mutton",
			[4] = "minecraft:cod",
			[5] = "minecraft:salmon",
			[6] = "minecraft:tropical_fish",
			[7] = "minecraft:pufferfish",
			[8] = "minecraft:rabbit",
			[9] = "minecraft:chicken",
			[10] = "minecraft:rotten_flesh",
			[11] = "minecraft:spider_eye",
			[12] = "minecraft:egg",
			[13] = "avaritia:neutron_nugget"
		},
	}
}

config.default(ENTRY_CONFIG, DEFAULT_CONFIG)

local config = config.load(ENTRY_CONFIG)

local recipes = config.recipes

while true do
	local ingredientsNeeded = {}

	for k, v in pairs(recipes[curRecipe]) do
		ingredientsNeeded[v] = ifnilretzero(ingredientsNeeded[v]) + 64
	end

	local clist = tempStorage.list()

	for k, v in pairs(ingredientsNeeded) do
		for k2, v2 in pairs(clist) do
			if v2.name == k then
				ingredientsNeeded[k] = ingredientsNeeded[k] - v2.count
			end
		end
	end

	for k, v in pairs(ingredientsNeeded) do
		if v > 0 then
			rs.exportItemToPeripheral({ name = k, count = v }, tmp)
		end
	end

	local tmpLocations = {}

	for k, v in pairs(tempStorage.list()) do
		tmpLocations[k] = v.name
	end

	for k, v in pairs(recipes[curRecipe]) do
		for k2, v2 in pairs(tmpLocations) do
			if v == v2 then
				crafter.pullItems(tmp, k2, STACK_SIZE, k)
				--print()
			end
		end
	end

	sleep(0.05)
end
