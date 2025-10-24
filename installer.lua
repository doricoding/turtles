local WGET = "wget"
local URL = "https://raw.githubusercontent.com/doricoding/turtles/refs/heads/main/"
local FILENAME = "structure.json"

local function getFiles()
    shell.run(WGET .. " " .. URL .. FILENAME)

    local file = fs.open(FILENAME, "r")
    local structure = textutils.unserialiseJSON(file.readAll())
    file.close()

    for i, v in ipairs(structure) do
        local command = WGET .. " " .. URL .. v .. " " .. v
        shell.run(command)
    end
end

shell.run("set motd.enable false")

local rootFiles = fs.list("/")

if #rootFiles-1 > 0 then
    print("Files found in root")
    while true do
        print("Type (Y/N) to delete all found files on the computer")
        local event, key, is_held = os.pullEvent("key")
        if key == keys.y or key == keys.n then
            if key == keys.y then
                for i, v in ipairs(rootFiles) do
                    if not fs.isReadOnly(v) then
                        fs.delete(v)
                    end
                end
                getFiles()
            else
                print("This might cause issues")
                getFiles()
            end
            break
        end
    end
else
    getFiles()
end