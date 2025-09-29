---@diagnostic disable-next-line: undefined-field
os.pullEvent = os.pullEventRaw;
local scanner = peripheral.wrap("back");
config.default("scan", {
	feature = {
		side_view = false,
		show_self = true,
	},
	groups = {
		blocks = {
			enabled = false,
			indicator = "B",
			keybind = "b",
			blocks = {
				["minecraft:ancient_debris"] = "brown",
				["minecraft:deepslate_gold_ore"] = "yellow",
				["minecraft:coal_ore"] = "gray",
				["minecraft:deepslate_iron_ore"] = "lightGray",
				["minecraft:gold_ore"] = "yellow",
				["minecraft:deepslate_emerald_ore"] = "green",
				["minecraft:deepslate_copper_ore"] = "orange",
				["minecraft:nether_quartz_ore"] = "white",
				["minecraft:deepslate_lapis_ore"] = "blue",
				["minecraft:redstone_ore"] = "red",
				["minecraft:deepslate_diamond_ore"] = "cyan",
				["minecraft:emerald_ore"] = "green",
				["minecraft:lapis_ore"] = "blue",
				["minecraft:nether_gold_ore"] = "yellow",
				["minecraft:diamond_ore"] = "cyan",
				["minecraft:iron_ore"] = "lightGray",
				["minecraft:deepslate_redstone_ore"] = "red",
				["minecraft:copper_ore"] = "orange",
				["minecraft:deepslate_coal_ore"] = "gray"
			},
		},
		liquids = {
			enabled = false,
			indicator = "L",
			keybind = "l",
			blocks = {
				["minecraft:water"] = "lightBlue",
				["minecraft:lava"] = "orange"
			}
		}
	}
});
local scan_config = config.load("scan");

-- Display
local color_under_player;
local function printBlock(block, color)
	if block["x"] == 0 and block["z"] == 0 then
		color_under_player = color;
	end
	term.setBackgroundColor(color);

	-- Topdown view
	local offset_col, offset_row;
	if scan_config.feature.side_view then
		if block["x"] < -2 or block["x"] > 4
			or block["z"] < -2 or block["z"] > 3 then
			goto skip_topdown;
		end

		offset_col, offset_row = 22, 17;
	else
		offset_col, offset_row = 10, 11;
	end
	term.setCursorPos(block["x"] + offset_col, block["z"] + offset_row);

	if block["y"] < 0 then
		term.setTextColor(colors.black);
	else
		term.setTextColor(colors.white);
	end
	term.write(math.abs(block["y"]));

	::skip_topdown::
	-- Side view
	if block["z"] ~= 0 then
		return;
	end

	if scan_config.feature.side_view then
		offset_col, offset_row = 10, 11;
	else
		if block["x"] < -2 or block["x"] > 3
			or block["y"] < -2 or block["y"] > 4 then
			return;
		end

		offset_col, offset_row = 22, 17;
	end
	term.setCursorPos(block["x"] + offset_col, -block["y"] + offset_row);
	term.write(" ");
end

local function printViewports()
	-- Corners
	term.setTextColor(colors.red);
	term.setCursorPos(1, 2);
	term.write("\x9C");
	term.setCursorPos(1, 20);
	term.write("\x8D");
	term.setCursorPos(19, 20);
	term.write("\x8E");
	term.setCursorPos(26, 12);
	term.write("\x90");
	term.setCursorPos(26, 20);
	term.write("\x81");

	term.setTextColor(colors.white);
	for i = 0, 16 do
		if i == 8 then
			term.setTextColor(colors.lime);
		elseif i % 2 == 0 then
			term.setTextColor(colors.lightGray);
		end
		term.setCursorPos(2 + i, 2);
		term.write("\x8C");
		term.setCursorPos(1, 3 + i);
		term.write("\x95");
		term.setCursorPos(2 + i, 20);
		term.write("\x8C");

		term.setTextColor(colors.white);
	end

	term.setTextColor(colors.black);
	term.setBackgroundColor(colors.red);
	term.setCursorPos(19, 2);
	term.write("\x93");
	for i = 0, 16 do
		if i == 8 then
			term.setBackgroundColor(colors.lime);
		elseif i == 14 then
			term.setBackgroundColor(colors.blue);
		elseif i % 2 == 0 then
			term.setBackgroundColor(colors.lightGray);
		end
		term.setCursorPos(19, 3 + i);
		term.write("\x95");

		term.setBackgroundColor(colors.white);
	end

	for i = 0, 5 do
		if i == 2 then
			term.setBackgroundColor(colors.blue);
		elseif i % 2 == 0 then
			term.setBackgroundColor(colors.lightGray);
		end

		term.setCursorPos(20 + i, 12);
		term.write("\x8F");

		term.setBackgroundColor(colors.white);
	end

	term.setBackgroundColor(colors.black);
	for i = 0, 5 do
		term.setTextColor(colors.white);
		if i == 2 then
			term.setTextColor(colors.blue);
		elseif i % 2 == 0 then
			term.setTextColor(colors.lightGray);
		end

		term.setCursorPos(20 + i, 20);
		term.write("\x83");
		term.setCursorPos(26, 19 - i);
		term.write("\x95");
	end

	term.setTextColor(colors.lightGray);
	term.setCursorPos(26, 13);
	term.write("\x95");
end

local blocks = {};
local function render()
	-- Display
	term.setBackgroundColor(colors.black);
	term.clear();

	printViewports();

	-- Print indicators
	term.setTextColor(colors.white);
	term.setBackgroundColor(colors.black);

	term.setCursorPos(1, 1);
	if scan_config.feature.side_view then
		term.write("S");
	else
		term.write("T");
	end

	if scan_config.feature.show_self then
		term.setCursorPos(2, 1);
		term.write("S");
	end
	local x = 3;
	for _, group in pairs(scan_config.groups) do
		if group.enabled then
			term.setCursorPos(x, 1);
			term.write(group.indicator);
		end
		x = x + 1;
	end

	-- Print content
	-- Blocks
	color_under_player = colors.black;
	for _, block in pairs(blocks) do
		for _, group in pairs(scan_config.groups) do
			if group.enabled then
				-- Check if block is in list
				for block_name, color_name in pairs(group.blocks) do
					if block_name == block["name"] then
						printBlock(block, colors[color_name] or colors.pink);
					end
				end
			end
		end
	end
	-- Self
	if scan_config.feature.show_self then
		term.setTextColor(colors.white);

		-- Main view
		if scan_config.feature.side_view then
			term.setBackgroundColor(colors.black);
			term.setCursorPos(10, 10);
			term.write("\x02");
			term.setCursorPos(10, 11);
			term.write("\x1F");
		else
			term.setBackgroundColor(color_under_player);
			term.setCursorPos(10, 11);
			term.write("\x02");
		end
		-- Secondary view
		if scan_config.feature.side_view then
			term.setBackgroundColor(color_under_player);
			term.setCursorPos(22, 17);
			term.write("\x02");
		else
			term.setBackgroundColor(colors.black);
			term.setCursorPos(22, 16);
			term.write("\x02");
			term.setCursorPos(22, 17);
			term.write("\x1F");
		end
	end
end

local loop = true;
while loop do
	parallel.waitForAny(
	-- Binds
		function()
			local _, keyCode = os.pullEvent("key");
			if keyCode == keys.q then
				-- Quit
				loop = false;
			elseif keyCode == keys.v then
				-- Change view
				scan_config.feature.side_view = not scan_config.feature.side_view;
			elseif keyCode == keys.s then
				-- Show self
				scan_config.feature.show_self = not scan_config.feature.show_self;
			else
				for _, group in pairs(scan_config.groups) do
					if keyCode == keys[group.keybind] then
						group.enabled = not group.enabled;
					end
				end
			end
		end,
		-- Scan
		function()
			::retry_block_scan::
			local scan_output = scanner.scan(8);
			if scan_output == nil then
				sleep(0.02);
				goto retry_block_scan;
			end
			blocks = scan_output;
			sleep(0.005);
		end
	);
	render();
end

term.setBackgroundColor(colors.black);
term.setCursorPos(1, 1);
term.clear();
