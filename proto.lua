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
---		-- public variables
---		myDefaultVariable1 = 0,
---		myDefaultVariable2 = "Example",
---	})
--- -- private variables
--- local myPrivateVariable1 = { "Elem1", "Elem2" }
--- function MyObject:setPrivateVariable1(tbl)
---		myPrivateVariable1 = tbl or {} --- failsafe to empty table.
---		return self --- allow chaining, i.e: MyObject:new():setPrivateVariable({ "Elem1" })
--- end
--- return MyObject
--- ```
function Proto.extend(from, defaults)
	local outputClass = defaults or {}
	outputClass.super = from or {}
	outputClass.exists = true
	for key, value in pairs(from) do
		if outputClass[key] == nil then
			outputClass[key] = value
		end
	end
	setmetatable(outputClass, {
		__tostring = function() return ("[Proto %s]"):format(outputClass._name or "Unknown(Custom)") end,
	})
	function outputClass:new(...)
		local current = {}
		setmetatable(current, outputClass)
		for k, v in pairs(outputClass) do
			if k ~= "__index" and k ~= "__newindex" and k ~= "super" and k ~= "exists" then
				-- prevent shared table states.
				current[k] = table.copy(v, true)
			end
		end
		if current.init then current:init(...) end
		return current
	end

	outputClass.__index = outputClass
	return outputClass, outputClass.super
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
	feature = feature or {}
	for k, v in pairs(feature) do
		if not self[k] or self[k] ~= v then
			self[k] = v
		end
	end
	return self
end

--- Returns the raw name of the object.
function Proto:type()
	return self._name or "Unknown(" .. self.super._name or "" .. ")"
end

setmetatable(Proto, {
	__tostring = function() return ("[Proto %s]"):format(to._name or "Proto") end,
})
Proto.__index = Proto

return Proto
