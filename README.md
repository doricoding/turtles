# Custom OS for Computer Craft + Advanced Peripherals
## Minecraft version
Minecraft Forge/NeoForge 1.20.1
## APIs
### Config (`/api/config.lua`)
API for reading and writing `.cfg` files in `/conf`

#### Config File Format
```
number = 70;
string = "Okey";
boolean = true;
table = {
	nested table = {
		1 = "First";
		2 = "Second";
	}
	empty = nil;
}
```

---
#### config.load(name)
Loads a config file from `/conf/{name}.cfg`

If the config is in a subdirectory you can still access it by calling `load("dir/name")`
##### Parameters
1. `name` - string (name of the config file being used)
##### Returns
- **table** - Generated from the contents of the config file
- **nil** - In case of a missing config file
##### Usage
**/conf/program.cfg**
```
number = 4;
"full sentence" = "Hello World!";
words = {
	hello = "Hello";
	world = "World";
}
```
**/prog/program.lua**
```lua
-- Loads the config file `/conf/program.cfg`
local program_config = config.load("program");
print(program_config.number) -- 4
print(program_config["full sentence"]) -- "Hello World!"
print(program_config.words.hello) -- "Hello"
print(program_config.words.world) -- "World"
```

---
#### config.save(name, data)
Saves a config file as `/conf/{name}.cfg`

If the config doesn't exist, one will be made
##### Parameters
1. `name` - string (name of the config file being used)
2. `data` - table (the information you wanna store into the config)
##### Usage
**/prog/program.lua**
```lua
-- Loads the config file `/conf/program.cfg`
local my_config = {
	["string"] = "Hi!",
	["table"] = {
		["boolean"] = true,
	}
};
my_config.number = 5;
-- Saves into file `/conf/program.cfg`
config.save("program", my_config);
```
**/conf/program.cfg**
```
string = "Hi!";
number = 5;
table = {
	boolean = true;
}
```

---
#### config.default(name, data)
Saves a config file as `/conf/{name}.cfg` if one **doesn't exist!**

Generates a config with default settings
##### Parameters
1. `name` - string (name of the config file being used)
2. `data` - table (the information you wanna store into the config)
##### Usage
**/prog/program.lua**
```lua
-- Setup a default config for your program
config.default("program", {
	["enable"] = true,
	["location"] = {
		["x"] = 0,
		["y"] = 0,
		["z"] = 0
	},
	["blacklist"] = {}
});

local program_config = config.load("program");
-- Rest of code
```

---
#### config.parse(content)
Parses a string in the config file format into a table
##### Parameters
1. `content` - string (A string containing the config file format)
##### Returns
- **table** - Generated from the string
##### Usage
**/prog/program.lua**
```lua
-- Parses the string into a table
local table = config.parse("a = 4; b = \"Minecraft\"; ");
print(table.a); -- 4
print(table.b); -- "Minecraft"
```

---
#### config.toString(data)
Converts a table into a config file formated string
##### Parameters
1. `data` - table (data you wanna convert into formated string)
##### Returns
- **string** - Config file formated string
##### Usage
**/prog/program.lua**
```lua
-- Parses the string into a table
local data = {
	["used"] = false,
	["ports"] = {
		["ssh"] = 22,
		["HTTP"] = 80
	}
};
local formated_string = config.toString(data);
print(formated_string);
```
**Output:**
```
used = false;
ports = {
	ssh = 22;
	HTTP = 80;
}
```
