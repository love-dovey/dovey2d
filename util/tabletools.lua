--- @author swordcube

-- Backwards compatibility
table.pack = table.pack or function(...)
	return { n = select("#", ...), ... }
end
table.unpack = table.unpack or unpack

function table.freeze(tbl)
	return setmetatable({}, {
		__index = tbl,
		__newindex = function(_, k, _)
			error(string.format("Attempt to modify a read-only table: %s", k), 2)
		end
	})
end

function table.find(tbl, val)
	for i, v in pairs(tbl) do
		if v == val then return i end
	end
	return nil
end

---
--- Makes a copy of a table.
---
--- @param tbl   table    The table to make a copy of.
--- @param deep? boolean  Whether or not all nested subtables should be deeply copied. If not, a shallow copy is performed, where only the top-level elements are copied.
--- @param been? table    A tracking table to deal with circular references properly, can be omitted.
---
--- @return table|nil
---
function table.copy(tbl, deep, been)
	if type(tbl) ~= "table" then return nil end
	been = been or {}
	if been[tbl] then return been[tbl] end
	local copied = {}
	been[tbl] = copied
	for k, v in pairs(tbl) do
		local key = deep and table.copy(k, deep, been) or k
		local val = deep and table.copy(v, deep, been) or v
		copied[key] = val
	end
	local mt = getmetatable(tbl)
	if mt then setmetatable(copied, mt) end
	return copied
end

---
--- Returns whether or not a table contains any
--- specified element.
---
--- @param tbl     table  The table to check.
--- @param element any    The element to check.
---
--- @return boolean
---
function table.has(tbl, element)
	for _, value in pairs(tbl) do
		if value == element then
			return true
		end
	end
	return false
end
