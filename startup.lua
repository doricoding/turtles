local HOME_DIR = "/home";
local MIXIN_DIR = "/api/mixin";
local API_DIR = "/api";
local AUTORUN = "/autorun.json";

-- Force startup to start in root
shell.run("cd /");

local apisToUnload = {
	"help",
	"rednet"
};

-- Unload default APIs
for _, api in pairs(apisToUnload) do
	os.unloadAPI(api);
end

-- Load mixins
for _, file in pairs(fs.list(MIXIN_DIR)) do
	shell.run(fs.combine(MIXIN_DIR, file));
end

-- Load custom APIs
for _, file in pairs(fs.list(API_DIR)) do
	local path = fs.combine(API_DIR, file);
	if not fs.isDir(path) then
		os.loadAPI(path);
	end
end

-- Run Autorun scripts
if fs.exists(AUTORUN) then
	local file = fs.open(AUTORUN, "r");
	local autorunEntries = textutils.unserializeJSON(file.readAll());
	file.close();
	if #autorunEntries > 0 then
		for _, entry in pairs(autorunEntries) do
			shell.run(entry);
		end
	else
		print("No entries in autorun file found!");
		shell.run(string.format("cd %s", HOME_DIR));
	end
else
	print("No autorun file found! Creating one ...");
	local file = fs.open(AUTORUN, "w");
	file.write("[]");
	file.close();
	shell.run(string.format("cd %s", HOME_DIR));
end

