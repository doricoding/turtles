local args = { ... };

local WGET = "wget";
local URL = "https://raw.githubusercontent.com/doricoding/turtles/refs/heads/main/";
local FILENAME_STRUCTURE = "structure.json";

local function isInList(val, list)
    local res = false;
    for _, v in ipairs(list) do res = res or (v == val) end
    return res;
end

local function getFiles()
    shell.run("cd /");
    shell.run(WGET.." "..URL..FILENAME_STRUCTURE);

    local file = fs.open(FILENAME_STRUCTURE, "r");
    local structure = textutils.unserialiseJSON(file.readAll());
    file.close();

    for i, v in ipairs(structure) do
        local command = WGET.." "..URL..v.." "..v;
        shell.run(command);
    end
end

local rootFiles = fs.list("/");

if #rootFiles-1 > 0 then
    print("Files found in root");
    while true do
        print("Type (Y/N) to delete all found files on the computer");
        local event, key, is_held = os.pullEvent("key");
        if (key == keys.y or key == keys.z) or key == keys.n then
            if (key == keys.y or key == keys.z) then
                for _, v in ipairs(rootFiles) do
                    if not fs.isReadOnly(v) and not isInList(v, {"rom", "disk"}) then
                        fs.delete(v);
                    end
                end
                getFiles();
            else
                while true do
                    print("Type (Y/N) to intall anyway");
                    local event, key, is_held = os.pullEvent("key");
                    if (key == keys.y or key == keys.z) or key == keys.n then
                        if (key == keys.y or key == keys.z) then
                            getFiles();
                        else
                            print("then no bozo");
                        end
                        break
                    end
                end
            end
            break
        end
    end
else
    getFiles();
end