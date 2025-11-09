local args = { ... };

local WGET = "wget";
local BRANCH = "main";
local PROJECT = "doricoding/turtles"
local URL = string.format("https://raw.githubusercontent.com/%s/refs/heads/%s/", PROJECT, BRANCH);
local FILENAME_STRUCTURE = "system_structure.json";
local TMP = "/.tmp";

local installerPath = shell.getRunningProgram()
local desiredInstallerPath = "/system_installer.lua"

if not fs.exists(desiredInstallerPath) then
    fs.copy(installerPath, desiredInstallerPath)
end

local function isInList(val, list)
    local res = false;
    for _, v in ipairs(list) do res = res or (v == val) end
    return res;
end

-- TODO: implement the file fetching from github
-- fetches file places it in /.tmp then it replaces the file if it exists already

shell.run("cd /");
shell.run(WGET.." "..URL..FILENAME_STRUCTURE);
shell.run(string.format("mkdir %s", TMP));

local file = fs.open(FILENAME_STRUCTURE, "r");
local structure = textutils.unserialiseJSON(file.readAll());
file.close();

for _, entry in pairs(structure) do
	local command = string.format("%s %s%s %s/%s", WGET, URL, entry, TMP, entry);
	shell.run(command);
	if fs.exsists(entry) then
		shell.run(string.format("rm %s", entry));
		shell.run(string.format("mv %s/%s %s", TMP, entry, entry));
	else
		shell.run(string.format("mv %s/%s %s", TMP, entry, entry));
	end
end

shell.run(string.format("rm %s", TMP));


