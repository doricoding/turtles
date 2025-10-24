local WGET = "wget"
local URL = "https://raw.githubusercontent.com/doricoding/turtles/refs/heads/main/"
local FILENAME = "structure.json"

shell.run(WGET .. " " .. URL .. FILENAME)

local file = fs.open(FILENAME, "r")
local structure = textutils.unserialiseJSON(file.readAll())
file.close()

local tmp = {}

for i, v in ipairs(structure) do
    local command = WGET .. " " .. URL .. v .. " " .. v
    table.insert(tmp, command)
    --shell.run(command)
end

textutils.pagedPrint(tmp)
