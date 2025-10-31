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
-- Find the correct closing bracket
local function findClosingBracket(content, index, opening_bracket)
	-- Get the closing bracket char
	local closing_bracket;
	if opening_bracket == "{" then
		closing_bracket = "}";
	elseif opening_bracket == "[" then
		opening_bracket = "%[";
		closing_bracket = "]";
	end

	local bracket_count = 1;
	local block_end = index + 1;

	while bracket_count > 0 do
		local start_open = content:find(opening_bracket, block_end) or math.huge;
		local start_close = content:find(closing_bracket, block_end) or math.huge;

		if start_open < start_close then
			bracket_count = bracket_count + 1;
			block_end = start_open + 1;
		else
			bracket_count = bracket_count - 1;
			block_end = start_close + 1;
		end
	end

	return block_end;
end
-- Parse inner recursive function
local function parseInner(content, is_array)
	local data = {};

	local index = 1;
	while true do
		-- Get key
		local key;
		if is_array then
			key = #data + 1;
		else
			local _, last = content:find("=", index);
			-- No next feild found (end of file)
			if last == nil then
				return data;
			end

			key = content:sub(index, last - 1);
			index = last + 1;
		end

		-- Get value
		local bracket = content:sub(index, index);
		if bracket == "{" or bracket == "[" then
			local block_end = findClosingBracket(content, index, bracket);

			-- Recursively parse inner values
			data[key] = parseInner(content:sub(index + 1, block_end - 2), bracket == "[");
			if (is_array and content:sub(block_end, block_end) == ",") 
			or (not is_array and content:sub(block_end, block_end) == ";") then
				block_end = block_end + 1;
			end;
			index = block_end;
		else
			local value;
			if is_array then
				local _, last = content:find(",", index);
				if last == nil then
					local last_value = content:sub(index, #content);
					if last_value ~= "" then
						data[key] = parseValue(last_value);
					end
					return data;
				end

				value = content:sub(index, last - 1);
				index = last + 1;
			else
				local _, last = content:find(";", index);
				value = content:sub(index, last - 1);
				index = last + 1;
			end

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

	return parseInner(simple_content, false);
end

local function toStringInner(data, indentation_level)
	local indentation = string.rep("\t", indentation_level);

	-- Check if table can be turned into an array
	local is_array = false;
	local array_index_counter = 0;
	for key, _ in pairs(data) do
		if type(key) ~= "number" then
			array_index_counter = 0;
			break;
		end
		array_index_counter = array_index_counter + 1;
	end
	if array_index_counter > 0 then
		for i = 1, array_index_counter do
			if data[i] == nil then
				break;
			end
		end

		is_array = true;
	end

	local content;
	if is_array then
		content = "[\n";
	else
		content = "{\n";
	end
	for key, value in pairs(data) do
		local value_type = type(value);
		if value_type == "string" then
			value = "\""..value.."\"";
		elseif value_type == "function" or value_type == "thread" or value_type == "userdata" then
			error("Unsuported value type: "..value_type);
		end

		if value_type == "table" then
			value = toStringInner(value, indentation_level + 1);
		elseif not is_array then
			value = tostring(value)..";";
		end

		if is_array then
			value = tostring(value);

			array_index_counter = array_index_counter - 1;
			if array_index_counter > 0 then
				value = value..",";
			end
		else
			value = key.." = "..value;
		end

		content = content..indentation..value.."\n";
	end

	-- Decrease indentation by 1
	indentation = indentation:sub(1, #indentation - 1);
	if is_array then
		content = content..indentation.."]";
	else
		content = content..indentation.."}";
	end
	return content;
end
-- Format table into string
function toString(data)
	local content = toStringInner(data, 0);
	-- Remove extra brackets in root
	return content:sub(2, #content - 1);
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
