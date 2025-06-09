--- Basic Object used as a basis for Object-oriented operations.
local Proto = {}

--- Initializes an empty object.
function Proto:init(...)
	--error("Method `init` must be implemented by a subclass.", 2)
	return self
end
--- Happens every frame.
function Proto:update(delta) error("Method `update` must be implemented by a subclass.", 2) end
--- Used to draw the object to the screen.
function Proto:draw() error("Method `draw` must be implemented by a subclass.", 2) end
--- Used to get rid of the object and release it from memory.
function Proto:dispose() error("Method `dispose` must be implemented by a subclass.", 2) end

--- Used to extend Object A for Object B
--- Example:
---
--- ```lua
--- local MyObject = Proto:extend({
---		myDefaultVariable1 = 0,
---		myDefaultVariable2 = "Example",
---	})
---
--- return MyObject
--- ```
function Proto.extend(from, defaults)
	local outputClass = defaults or {}
	outputClass.super = from
	outputClass.exists = true
	for key, value in pairs(from) do
		if outputClass[key] == nil then
			outputClass[key] = value
		end
	end
	setmetatable(outputClass, {
		__tostring = function() return ("[Proto %s]"):format(outputClass._name or "Unknown (Custom)") end,
	})
	function outputClass:new(...)
		setmetatable(self, outputClass)
		if self.init then self:init(...) end
		return self
	end
	outputClass.__index = outputClass
	return outputClass, outputClass.super or {}
end

-- https://github.com/rxi/classic/blob/e5610756c98ac2f8facd7ab90c94e1a097ecd2c6/classic.lua#L44
-- TODO: this kinda doesn't work you know??????
--- Checks if an Object is of the same type as another object.
function Proto:is(cls)
	local mt = getmetatable(self)
	while mt do
		if mt == cls then return true end
		mt = getmetatable(mt)
	end
	return false
end

setmetatable(Proto, {
	__tostring = function() return ("[Proto %s]"):format(to._name or "Proto") end,
})
Proto.__index = Proto

return Proto
