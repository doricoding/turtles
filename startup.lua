local HOME = "/home"
local API_DIR = "/api";
local AUTORUN_DIR = "/autorun"

-- Unload default APIs
os.unloadAPI("help");
os.unloadAPI("rednet");
-- Load custom APIs
for _, file in pairs(fs.list(API_DIR)) do
	os.loadAPI(API_DIR.."/"..file);
end

-- Run Autorun scripts
for _, file in pairs(fs.list(AUTORUN_DIR)) do
	shell.run(AUTORUN_DIR.."/"..file)
end

-- Set starting directory to HOME
shell.run("cd "..HOME);
