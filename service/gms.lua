config.default("gms", {
	modem = {
		center = "",
		x = "",
		y = "",
		z = ""
	},
	position = {
		x = 0,
		y = 0,
		z = 0
	}
});
local gms_config = config.load("gms");

local modem_c = peripheral.wrap(gms_config.modem.center);
local modem_x = peripheral.wrap(gms_config.modem.x);
local modem_y = peripheral.wrap(gms_config.modem.y);
local modem_z = peripheral.wrap(gms_config.modem.z);
-- Open ports (only limited to 128 at once :/)
for p = 0, 127 do
	modem_c.open(p);
	modem_x.open(p);
	modem_y.open(p);
	modem_z.open(p);
end

local function calculatePosition(distances)
	local dx, dy, dz = distances[gms_config.modem.x], distances[gms_config.modem.y], distances[gms_config.modem.z];
	local dc_squared = distances[gms_config.modem.center] ^ 2;

	local x = (dc_squared - dx ^ 2 + 9) / 6;
	local y = (dc_squared - dy ^ 2 + 9) / 6;
	local z = (dc_squared - dz ^ 2 + 9) / 6;

	return {
		gms_config.posittion.x + x,
		gms_config.posittion.y + y,
		gms_config.posittion.z + z
	};
end

local distances = {};
while true do
	local side, channel, reply, content, distance;
	for i = 1, 4 do
		_, side, channel, reply, content, distance = os.pullEvent("modem_message");
		distances[side] = distance;
	end

	local position = calculatePosition(distances);
	local log = "[" ..
	os.date("%T") .. "] " .. reply .. " -> " .. channel ..
	" at {" .. position[1] .. ", " .. position[2] .. ", " .. position[3] .. "}";
	print(log);

	local log_file = fs.open("/logs/gms/" .. os.date("%Y-%m-%d") .. ".log", "a");
	log_file.writeLine(log);
	log_file.close();
end
