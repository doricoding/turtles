local WGET = "wget"
local URL = "https://raw.githubusercontent.com/doricoding/turtles/refs/heads/main/"
local FILENAME = "structure.json"

shell.run(WGET .. " " .. URL .. FILENAME)

local file = fs.open(FILENAME, "r")
local structure = textutils.unserialiseJSON(file.readAll())
file.close()

local files = {}

local function rec(key, val)
    local FILE = "file"
    local DIR = "directory"
    if key == FILE then
        for i, v in ipairs(val) do
            table.insert(files, v)    
        end
    elseif key == DIR then
        for k, v in pairs(val) do 
            rec(k, v)
         end
    else
        print("error")
    end
end

for k, v in pairs(structure) do
    rec(k, v)
end


local tmp = table.concat(files, "\n")

textutils.pagedPrint(tmp)
--do the file requesting here

