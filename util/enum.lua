--- Makes an enum (fancy table with some helper methods)
--- ```lua
--- local Values = Enum("Values", "VALUE1", "VALUE2")
--- -- you can use a number to access
--- print(Values.resolve(1)) -- "VALUE1"
--- -- or a string
--- print(Values.resolve("VALUE2")) -- "VALUE2"
--- -- inexistent values fall back to the first
--- print(Values.resolve(5)) -- "VALUE1"
--- -- there's also a function to stringify values.
--- print(Value.str(1)) -- "VALUE1"
--- ```
local function makeEnum(name, ...)
	--- @class Enum
	local newEnum = { ... }
	newEnum._name = "Enum(" .. tostring(name or "Nameless") .. ")"
	-- Reverse mappings are stored both for number AND for string.
	for k, v in pairs(newEnum) do
		if type(k) == "string" then k = string.lower(k) end
		newEnum[v] = k
	end
	newEnum.str = function(t)
		for k, v in pairs(newEnum) do
			if v == t then return k end
		end
	end
	newEnum.resolve = function(input)
		if type(input) == "number" then
			return math.round(input)
		elseif type(input) == "string" then
			input = input:lower():gsub("%s+", "")
			return newEnum[input:upper()] or newEnum[newEnum[1]]
		end
		return newEnum[newEnum[1]]
	end
	return newEnum
end

return makeEnum
