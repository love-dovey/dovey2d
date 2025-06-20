--- Basic Object used as a basis for Object-oriented operations.
local Proto = {}

--- Initializes an empty object.
function Proto:init(...)
	Log.error("Method `init` must be implemented by a subclass.", 2)
	return self
end

--- Happens every frame.
function Proto:update(delta)
	--Log.warn("Method `update` must be implemented by a subclass.", true)
end

--- Used to draw the object to the screen.
function Proto:draw()
	--Log.warn("Method `draw` must be implemented by a subclass.", true)
end

--- Used to get rid of the object and release it from memory.
function Proto:dispose()
	--Log.warn("Method `dispose` must be implemented by a subclass.", true)
end

--- Used to extend Object A for Object B
--- Example:
---
--- ```lua
--- local MyObject = Proto:extend({
---		-- public properties
---		publicStr = "Example",
---		publicNum = 0,
---	})
--- -- private property
--- local _priv = { "Elem1", "Elem2" }
---
--- -- get/set
---
--- function MyObject:pget_publicNum()
---		local n = self.publicNum
---		-- never less than 0, never greater than 100, never a decimal (always rounded)
---		return math.min(math.max(math.floor(n + 0.5), 0), 100)
---	end
---
--- function MyObject:pset_publicNum(n)
---		if type(n) ~= "table" then
---			-- push warning if needed.
---			Log.warn("Cannot set publicNum property to a value that isn't a number.")
---			return self
---		end
---		self.publicNum = n
---		-- returning here is optional.
---		return self.publicNum
--- end
--- return MyObject
--- ```
function Proto.extend(from, defaults)
	local derivation = defaults or {}
	local devmt = {
		__index = function(self, key)
			if string.starts(key, "pget_") then
				local getter = rawget(self, key)
				if type(getter) == "function" then return getter() end
			end
			local value = rawget(self, key)
			if value ~= nil then return value end
			local upclass = getmetatable(self).__upclass
			while upclass do
				local val = rawget(upclass, key)
				if val ~= nil then return val end
				upclass = getmetatable(upclass) -- recursion
			end
			return nil
		end,
		__newindex = function(self, key, value)
			if string.starts(key, "pset_") then
				local setter = rawget(self, key)
				if type(setter) == "function" then
					return setter(value)
				end
			end
			rawset(self, key, value)
		end,
	}
	setmetatable(derivation, from or {})
	derivation.exists = true

	function derivation:new(...)
		local current = {}
		setmetatable(current, {
			__index = devmt.__index,
			__newindex = devmt.__newindex,
			__upclass = derivation, -- tried without it and it didn't work.
		})
		for k, v in pairs(derivation) do
			if k ~= "__index" and k ~= "__newindex" and k ~= "super" and k ~= "exists" then
				-- prevent shared table states.
				current[k] = table.copy(v, true)
			end
		end
		if current.init then current:init(...) end
		return current
	end
	return derivation, from or {}
end

-- https://github.com/rxi/classic/blob/e5610756c98ac2f8facd7ab90c94e1a097ecd2c6/classic.lua#L44
--- Checks if an Object is of the same type as another object.
function Proto:is(cls)
	local mt = getmetatable(self)
	while mt do
		if mt == cls then return true end
		mt = getmetatable(mt)
	end
	return false
end

function Proto:implement(feature)
	for k, v in pairs(feature or {}) do
		if self[k] == nil or self[k] ~= v then
			self[k] = v
		end
	end
	return self
end

--- Returns the raw name of the object.
function Proto:type()
	return self._name or (getmetatable(self) and getmetatable(self)._name) or "Unknown"
end

setmetatable(Proto, {
	__tostring = function(self) return ("[Proto %s]"):format(self._name or "Proto") end,
})
Proto.__index = Proto

return Proto
