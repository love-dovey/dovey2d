function string.table(tbl, indent)
	if type(tbl) ~= "table" then return tostring(tbl) end
	indent = indent or 0
	local _str = "{\n"
	local pad = string.rep("  ", indent + 1)
	for k, v in pairs(tbl) do
		local key = tostring(k)
		local value = tostring(v)
		if type(v) == "table" then
			value = string.table(v, indent + 1)
		end
		if type(v) == "string" then value = "\"" .. tostring(v) .. "\"" end
		_str = _str .. pad .. key .. " = " .. value .. ",\n"
	end
	_str = _str .. string.rep("  ", indent) .. "}"
	local name = ""
	if tbl._name then name = "(" .. tostring(tbl._name) .. ")" end
	return tostring(tbl) .. name .. " " .. _str
end

function string.starts(x, beginning)
	return string.sub(x, 1, #beginning) == beginning
end

function string.endswith(x, ending)
	return string.sub(x, - #ending) == ending
end

--- Trims a string using a pattern, trims spaces by default.
---
--- Sort of serves as a shortcut to string.gsub() with default patterns.
--- see [§6.4.1](https://www.lua.org/manual/5.4/manual.html#6.4.1)
--- @param x string
--- @param customPattern? string
--- @param replacement? string
function string.trim(x, customPattern, replacement)
	local p = type(customPattern) == "string" and customPattern or "%s+"
	local r = type(replacement) == "string" and replacement or ""
	return string.gsub(x, p, r)
end

--- Puts elements of a string in a table depending on the delimiter.
--- @param x string
--- @param delimiter string
--- @param trimSpaces boolean 		Trims spaces from the resulting table keys.
--- ```lua
--- local combo = string.split("500", "")
--- print(string.table(combo)) -- table 0x... {
---		1 = "5",
---		2 = "0",
---		3 = "0"
---	}
--- local commaSeparated = ("apple,orange,banana"):split(",")
---	print(string.table(commaSeparated)) -- table 0x... {
---		1 = "apple",
---		2 = "orange",
---		3 = "banana",
---	}
--- ```
function string.split(x, delimiter, trimSpaces)
	if #x == 0 then return {} end
	if trimSpaces == nil then trimSpaces = false end
	local out = {}
	if delimiter == "" then
		-- insert every element.
		for i = 1, #x do
			local character = string.sub(x, i, i)
			out[i] = trimSpaces and string.trim(x)
		end
	else
		-- insert only elements after the delimiter.
		for character in string.gmatch((x .. delimiter), "(.-)" .. delimiter) do
			table.insert(out, trimSpaces and string.trim(character) or character)
		end
	end
	return out
end

--- Similar to string.split, but splits the entire string for only words.
--- @param x string
function string.splitwords(x)
	local words = {}
	for word in x:gmatch("%S+%s*") do
		table.insert(words, word)
	end
	return words
end