--- Base for every other class in the Engine.
--- @class Object
local Object = {}

--- Initializes an empty object.
function Object:init(...)
	Log.error("Method `init` must be implemented by a subclass.")
	return self
end

--- Initializes the fields of the object.
function Object:initFields(fields)
	for k, v in pairs(fields) do
		--if rawget(self, k) ~= nil then
		--	Log.warn("Field '" .. k .. "' already exists in object: possible override.")
		--end
		self[k] = type(v) == "table" and table.copy(v, true) or v
	end
end

--- Binds a method name to the object, returning a callable that retains self.
--- @param methodName string
--- @return function
function Object:bind(methodName)
	local method = self[methodName]
	if type(method) ~= "function" then
		error(("Cannot bind non-function '%s' from %s"):format(tostring(methodName), tostring(self:type())), 2)
	end
	return function(...)
		return method(self, ...)
	end
end

--- Happens every frame.
function Object:update(delta)
	--Log.warn("Method `update` must be implemented by a subclass.", true)
end

--- Used to draw the object to the screen.
function Object:draw()
	--Log.warn("Method `draw` must be implemented by a subclass.", true)
end

--- Used to get rid of the object and release it from memory.
function Object:dispose()
	--Log.warn("Method `dispose` must be implemented by a subclass.", true)
end

local function implement(self, feature, ignores)
	if type(ignores) ~= "table" then ignores = {} end

	local ignoreSet = {}
	if type(ignores) == "table" then
		for _, key in ipairs(ignores) do
			ignoreSet[key] = true
		end
	end

	for k, v in pairs(feature or {}) do
		if self[k] == nil and not ignoreSet[k] then
			if type(v) == "table" then
				if v.clone then
					self[k] = getmetatable(v) and v:clone() or v.clone()
				else
					self[k] = table.copy(v, true)
				end
			else
				self[k] = v
			end
		end
	end
	return self
end


--local function publicFunc(self, name, func) self._public[name] = func end
--local function privateFunc(self, name, func) self._private[name] = func end
--local function protectedFunc(self, name, func) self._protec[name] = func end
--local function initClass()
--	return {
--		_public = {},
--		_private = {},
--		_protected = {},
--	}
--end

local function extend(from, defaults)
	local derivation = defaults or {}
	local super = from or {}
	derivation.implement = implement
	derivation.extend = extend

	--local function getProperty(tbl, k)
	--	-- check all tables, highest access level to lowest.
	--	if tbl.__public[k] ~= nil then return tbl.__public[k] end
	--	if tbl.__protected[k] ~= nil then return tbl.__protected[k] end
	--	return tbl.__private[k]
	--end
	--local function setProperty(tbl, k, v)
	--	if tbl.__public[k] ~= nil then tbl.__public[k] = v end
	--	if tbl.__protected[k] ~= nil then tbl.__protected[k] = v end
	--	tbl.__private[k] = v
	--end

	setmetatable(derivation, super)
	derivation.exists = true

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

	function derivation:new(...)
		local current = {}
		setmetatable(current, {
			__index = function(self, key)
				local getter = getterF(self, key)
				if getter then return getter(self) end
				local value = rawget(self, key)
				if value ~= nil then return value end
				local upclass = getmetatable(self).__upclass
				while upclass do
					local val = rawget(upclass, key)
					if val ~= nil then return val end
					upclass = getmetatable(upclass)
				end
				return nil
			end,
			__newindex = function(tbl, key, value)
				local setter = setterF(tbl, key)
				if setter then return setter(tbl, value) end
				rawset(tbl, key, value)
			end,
			__upclass = derivation
		})
		current.super = super
		for k, v in pairs(derivation) do
			if k ~= "__index" and k ~= "__newindex" and k ~= "__upclass" and k ~= "super" then
				current[k] = table.copy(v, true)
			end
		end
		if current.init then current:init(...) end
		return current
	end

	return derivation, super
end

--- Used to extend Object A for Object B
--- Example:
---
--- ```lua
--- local MyObject = dovey.Object:extend({
---		-- public properties
---		publicStr = "Example",
--- 	publicNum = 0,
---	})
--- -- private property.
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
--- @return metatable, metatable|table
Object.extend = extend

-- https://github.com/rxi/classic/blob/e5610756c98ac2f8facd7ab90c94e1a097ecd2c6/classic.lua#L44
--- Checks if an Object is of the same type as another object.
function Object:is(cls)
	local mt = getmetatable(self)
	while mt do
		if mt == cls then return true end
		mt = getmetatable(mt)
	end
	return false
end

--- Returns the raw name of the object.
function Object:type()
	return self._name or (getmetatable(self) and getmetatable(self)._name) or "Unknown"
end

function Object:printAllProperties()
	local props = {}
	for k, v in pairs(self) do
		props[k] = v
	end
	print(props)
end

setmetatable(Object, {
	__tostring = function(self) return ("[%s]"):format(self._name or "Object") end,
})
Object.__index = Object

return Object
