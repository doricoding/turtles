local HOME_DIR = "/home";
local MIXIN_DIR = "/api/mixin";
local API_DIR = "/api";
local AUTORUN_DIR = "/autorun";

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
if fs.exists(AUTORUN_DIR) then
	for _, file in pairs(fs.list(AUTORUN_DIR)) do
		shell.run(fs.combine(AUTORUN_DIR, file));
	end
else
	print("No autorun directory found");
end

-- Set starting directory to HOME for convenience
shell.run("cd "..HOME_DIR);
