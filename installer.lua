local args = { ... };

local completion = require("cc.completion");

local WGET = "wget";
local BRANCH = "main";
local PROJECT = "doricoding/turtles";
local URL = string.format("https://raw.githubusercontent.com/%s/refs/heads/%s/", PROJECT, BRANCH);
local FILENAME_STRUCTURE = "structure.json";
local TMP = "/.tmp";

local installerPath = shell.getRunningProgram()
local desiredInstallerPath = "/installer.lua"

if not fs.exists(desiredInstallerPath) then
    fs.copy(installerPath, desiredInstallerPath)
end

local function isInList(val, list)
    local res = false;
    for _, v in ipairs(list) do res = res or (v == val) end
    return res;
end

shell.run("cd /");
shell.run(string.format("%s %s%s", WGET, URL, FILENAME_STRUCTURE));

if #args > 0 then
	-- TODO: implement argument parser
	print("not implemented yet!");
else
	print("Choose file to install");
	local file = fs.open(FILENAME_STRUCTURE, "r");
	local structure = textutils.unserialiseJSON(file.readAll());
	file.close();
	local input = read(nil, nil, function(a_v)
		return completion.choice(a_v, structure)
	end, nil);
	if input ~= nil and isInList(input, structure) then
		shell.run(string.format("%s %s%s %s/%s", WGET, URL, input, TMP, input));
		if fs.exists(input) then
			shell.run(string.format("rm %s", input));
		end
		shell.run(string.format("mv %s/%s %s", TMP, input, input));
	else
		print(string.format("%s: File not found in structure or is nil. If you want file that is not in structure use --help"));
	end
end
