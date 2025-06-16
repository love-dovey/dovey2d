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

--- Puts elements of a string in a table depending on the delimiter.
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
function string.split(x, delimiter)
	if #x == 0 then return {} end
	local out = {}
	if delimiter == "" then
		-- insert every element.
		for i = 1, #x do
			out[i] = string.sub(x, i, i)
		end
	else
		-- insert only elements after the delimiter.
		for character in string.gmatch((x .. delimiter), "(.-)" .. delimiter) do
			table.insert(out, character)
		end
	end
	return out
end
