local chat = peripheral.find("chatBox")
local machine = peripheral.find("playerDetector")
local relay = peripheral.wrap("redstone_relay_0")
 
local RELAY_OUT_SIDE = "right"
local greet = true
 
if greet then math.randomseed(math.sin(os.time("utc"))) end
local greetMessages = {
    "Wassup %s",
    "Rise and shine, %s",
    "Good day mister %s",
    "%s joined like a Good Boy :3"
}
 
print("Prog started range_toggle.lua")
 
local function updateStatus(val)
    if val == 0 then
        relay.setOutput(RELAY_OUT_SIDE, true)
    else
        relay.setOutput(RELAY_OUT_SIDE, false)
    end
end
 
local playerAmount = #machine.getOnlinePlayers()
 
updateStatus(playerAmount)
 
while true do
    local event = {os.pullEvent()}
    local eventName = event[1]
        
    if eventName == "playerJoin" then
        playerAmount = playerAmount + 1
        local playerName = event[2]
        updateStatus(playerAmount)
        if greet then chat.sendMessage(string.format(greetMessages[math.floor((math.random(1, #greetMessages)+0.5))], playerName)) end
    elseif eventName == "playerLeave" then
        playerAmount = playerAmount - 1
        updateStatus(playerAmount)
    end
end