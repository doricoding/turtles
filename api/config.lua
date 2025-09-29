local CONFIG_PATH = "/conf";
local CONFIG_FILE_EXTENTION = ".cfg";

-- Parse value feild (non-table only)
local function parseValue(value)
	if value == "true" then
		return true;
	elseif value == "false" then
		return false;
	elseif value == "nil" then
		return nil;
	end

	return tonumber(value) or value;
end
-- Parse inner recursive function
local function parseInner(content)
	local data = {};

	local index = 1;
	while true do
		-- Get key
		local _, last = content:find("=", index);
		-- No next key found (end of file)
		if last == nil then
			return data;
		end
		local key = content:sub(index, last - 1);
		index = last + 1;

		-- Get value
		local value;
		if content:sub(index, index) == "{" then
			local bracket_count = 1;
			local block_end = index + 1;
			-- Find the correct closing bracket
			while bracket_count > 0 do
				local start_open = content:find("{", block_end) or math.huge;
				local start_close = content:find("}", block_end) or math.huge;

				if start_open < start_close then
					bracket_count = bracket_count + 1;
					block_end = start_open + 1;
				else
					bracket_count = bracket_count - 1;
					block_end = start_close + 1;
				end
			end

			-- Recursively parse inner table
			data[key] = parseInner(content:sub(index + 1, block_end - 2));
			if content:sub(block_end, block_end) == ";" then
				block_end = block_end + 1;
			end;
			index = block_end;
		else
			local _, last = content:find(";", index);
			value = content:sub(index, last - 1);
			index = last + 1;

			data[key] = parseValue(value);
		end
	end
end
-- Parse config string into table
function parse(content)
	-- Remove whitespace
	local index = 1;
	local inside = false;
	local simple_content = "";
	while index ~= math.huge do
		local quote_index = content:find("\"", index) or math.huge;

		local substring = content:sub(index, quote_index - 1);
		if inside then
			simple_content = simple_content..substring;
		else
			simple_content = simple_content..string.gsub(substring, "%s", "");
		end
		inside = not inside;
		index = quote_index + 1;
	end

	return parseInner(simple_content);
end

local function toStringInner(data, indentation_level)
	local indentation = string.rep("\t", indentation_level);
	local content = "";
	for key, value in pairs(data) do
		local value_type = type(value);
		if value_type == "string" then
			value = "\""..value.."\"";
		elseif value_type == "function" or value_type == "thread" or value_type == "userdata" then
			error("Unsuported value type: "..value_type);
		end

		if value_type == "table" then
			value = "{\n"..toStringInner(value, indentation_level + 1)..indentation.."}";
		else
			value = tostring(value)..";";
		end

		content = content..indentation..key.." = "..value.."\n";
	end

	return content;
end
-- Format table into string
function toString(data)
	return toStringInner(data, 0);
end

-- Load and parse a config file
function load(name)
	local file = fs.open(CONFIG_PATH.."/"..name..CONFIG_FILE_EXTENTION, "r");
	-- Config file doesn't exist
	if file == nil then
		return nil;
	end
	local content = file.readAll();
	file.close();

	return parse(content);
end
-- Save table into config file
function save(name, data)
	assert(data, "Missing data argument!");
	local content = toString(data);
	local file = fs.open(CONFIG_PATH.."/"..name..CONFIG_FILE_EXTENTION, "w");
	file.write(content);
	file.close();
end
-- Define the default config for a program
function default(name, data)
	if fs.exists(CONFIG_PATH.."/"..name..CONFIG_FILE_EXTENTION) == false then
		save(name, data);
	end
end
