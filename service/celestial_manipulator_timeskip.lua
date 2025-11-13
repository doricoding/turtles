local SIDE_CELESTIAL_MANIP = "top";
-- fix time offset when time moves?
local timeOffset = 1.99813842792;
local skipTimeTrigger = 18.5;
local use24hourFormat = true

while true do
	local time = os.time("ingame");
	if time > skipTimeTrigger then
		print(string.format("Skipping time at %s", textutils.formatTime(os.time("utc") + timeOffset, use24hourFormat)));
		redstone.setOutput(SIDE_CELESTIAL_MANIP, true);
		sleep(1);
		redstone.setOutput(SIDE_CELESTIAL_MANIP, false);
		sleep(60);
	end
end
