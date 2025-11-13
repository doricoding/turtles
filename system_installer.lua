--local args = { ... };

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

shell.run("cd /");
shell.run(string.format("%s %s%s", WGET, URL, FILENAME_STRUCTURE));
shell.run(string.format("mkdir %s", TMP));

local file = fs.open(FILENAME_STRUCTURE, "r");
local structure = textutils.unserialiseJSON(file.readAll());
file.close();

for _, entry in pairs(structure) do
	local command = string.format("%s %s%s %s/%s", WGET, URL, entry, TMP, entry);
	shell.run(command);
	if fs.exists(entry) then
		shell.run(string.format("rm %s", entry));
	end
	shell.run(string.format("mv %s/%s %s", TMP, entry, entry));
end

shell.run(string.format("rm %s", TMP));


