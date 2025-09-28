local C = "right";
local X = "modem_0";
local Y = "modem_1";
local Z = "modem_2";
local COORDS = {6514, -59, 2346};

local modem_c = peripheral.wrap(C);
local modem_x = peripheral.wrap(X);
local modem_y = peripheral.wrap(Y);
local modem_z = peripheral.wrap(Z);
-- Open ports (only limited to 128 at once :/)
for p=0, 127 do
    modem_c.open(p);
    modem_x.open(p);
    modem_y.open(p);
    modem_z.open(p);
end
 
local function calculatePosition(distances)
    local dx, dy, dz = distances[X], distances[Y], distances[Z];
    local dc_squared = distances[C] ^ 2;
 
    local x = (dc_squared - dx^2 + 9) / 6;
    local y = (dc_squared - dy^2 + 9) / 6;
    local z = (dc_squared - dz^2 + 9) / 6;
 
    return {
  COORDS[1] + x,
  COORDS[2] + y,
  COORDS[3] + z
 };
end
 
local distances = {};
while true do
    local side, channel, reply, content, distance;
    for i=1, 4 do
        _, side, channel, reply, content, distance = os.pullEvent("modem_message");
  distances[side] = distance;
    end
 
    local position = calculatePosition(distances);
 local log = "["..os.date("%T").."] "..reply.." -> "..channel.." at {"..position[1]..", "..position[2]..", "..position[3].."}";
 print(log);
 
 local log_file = fs.open("/logs/gms/"..os.date("%Y-%m-%d")..".log", "a");
 log_file.writeLine(log);
 log_file.close();
end
 