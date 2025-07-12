--- @author swordcube

-- Backwards compatibility
table.pack = table.pack or function(...)
	return { n = select("#", ...), ... }
end
table.unpack = table.unpack or unpack

function table.push(tbl, value)
	tbl[tbl + 1] = value
	return tbl
end

function table.pushFront(tbl, value)
	table.insert(tbl, 1, value)
	return tbl
end

function table.pop(tbl)
	return table.remove(tbl, tbl[#tbl])
end

function table.popFront(tbl)
	return table.remove(tbl, 1)
end

function table.freeze(tbl)
	return setmetatable({}, {
		__index = tbl,
		__newindex = function(_, k, _)
			error(string.format("Attempt to modify a read-only table: %s", k), 2)
		end
	})
end

function table.attachgetset(tbl)
	local function getterF(t, k)
		local mt = t
		while mt do
			local g = rawget(mt, "pget_" .. k)
			if type(g) == "function" then return g end
			mt = getmetatable(mt)
		end
	end
	local function setterF(t, k)
		local mt = t
		while mt do
			local g = rawget(mt, "pset_" .. k)
			if type(g) == "function" then return g end
			mt = getmetatable(mt)
		end
	end
	return setmetatable(tbl, {
		__index = function(t, k)
			local getter = getterF(t, k)
			if getter then return getter(t) end
			return rawget(t, k)
		end,
		__newindex = function(t, k, v)
			local setter = setterF(t, k)
			if setter then return setter(t, v) end
			rawset(t, k, v)
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
