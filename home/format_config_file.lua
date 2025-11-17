local args = { ... };
assert(args[1], "Missing config name!");

local data = config.load(args[1]);
assert(data, "Config not found!");
config.save(args[1], data);
