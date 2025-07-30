local UNKNOWN_ACTION = "#unknown_action"

local Signal = require("dovey.util.signal")
--- Utility for handling inputs.
--- @type table
local Input = {
	_name     = "Input",
	actions   = {
		["ui_down"]   = { "down" },
		["ui_left"]   = { "left" },
		["ui_right"]  = { "right" },
		["ui_up"]     = { "up" },
		["ui_accept"] = { "return" },
		["ui_cancel"] = { "backspace" },
		["ui_pause"]  = { "pause" },
	},
	onKeyDown = Signal:new(),
	onKeyUp   = Signal:new(),
}
local pressed = {}
local released = {}
local keyPressed = {}
local keyReleased = {}

function Input.update(_)
	pressed = {}
	released = {}
	keyPressed = {}
	keyReleased = {}
end

function Input.keyUp(key, scancode, isrepeat)
	local actions = Input.getActionFromKey(scancode)
	for _, action in ipairs(actions) do
		Input.onKeyUp:emit(false, scancode, action)
		if Engine.activeCanvas and Engine.activeCanvas.onKeyReleased then
			Engine.activeCanvas:onKeyReleased(key, action, isrepeat)
		end
	end
end

function Input.keyDown(key, scancode, isrepeat)
	local actions = Input.getActionFromKey(scancode)
	for _, action in ipairs(actions) do
		Input.onKeyDown:emit(true, scancode, action)
		if Engine.activeCanvas and Engine.activeCanvas.onKeyPressed then
			Engine.activeCanvas:onKeyPressed(key, action, isrepeat)
		end
	end
end

--- Checks if one of the action keys is being held down.
--- @return boolean true/false depending on if the key is held down.
function Input.isDown(actionName)
	if Input.hasAction(actionName) then
		for _, key in ipairs(Input.actions[actionName]) do
			if love.keyboard.isDown(key) then
				pressed[actionName] = { keyCode = key, action = actionName }
				return true
			end
		end
	end
	return false
end

--- Checks if one of the action keys was pressed in the current frame.
--- @return boolean true/false depending on if the key was pressed in this frame.
function Input.wasDown(actionName)
	if Input.hasAction(actionName) then
		for _, key in ipairs(Input.actions[actionName]) do
			if love.keyboard.isDown(key) and not pressed[actionName] then
				pressed[actionName] = { keyCode = key, action = actionName }
				return true
			end
		end
	end
	return false
end

--- Checks if one of the action keys was released in the current frame.
--- @return boolean true/false depending on if the key was released in this frame.
function Input.wasUp(actionName)
	if Input.hasAction(actionName) then
		for _, key in ipairs(Input.actions[actionName]) do
			if not love.keyboard.isDown(key) and not released[actionName] then
				released[actionName] = { keyCode = key, action = actionName }
				return true
			end
		end
	end
	return false
end

--- Checks if one keycode was pressed in the current frame.
--- @return boolean true/false depending on if the key was pressed in this frame.
function Input.wasKeyDown(key)
	if love.keyboard.isDown(key) and not keyPressed[key] then
		keyPressed[key] = { keyCode = key }
		return true
	end
	return false
end

--- Checks if one keycode was released in the current frame.
--- @return boolean true/false depending on if the key was released in this frame.
function Input.wasKeyUp(key)
	if not love.keyboard.isDown(key) and not released[key] then
		keyReleased[key] = { keyCode = key }
		return true
	end
	return false
end

--- Returns a value between -1 and 1 based on two opposing actions
--- @param positiveAction string The action to return 1 for
--- @param negativeAction string The action to return -1 for
--- @return number -1, 0, or 1 depending on which action is pressed
function Input.axis(positiveAction, negativeAction)
	if Input.isDown(positiveAction) then return 1
	elseif Input.isDown(negativeAction) then return -1
	else return 0 end
end

--- Adds a new action to the actions table.
---
--- @see https://love2d.org/wiki/KeyConstant for Key Codes.
--- @param actionName string		Self-explanatory.
--- @param key string|table 		A keycode string or table with keycodes.
function Input.addAction(actionName, key)
	if Input.actions[actionName] == nil then
		Input.actions[actionName] = {}
	end

	if type(key) == "string" then
		table.insert(Input.actions[actionName], key)
	elseif type(key) == "table" then
		Input.actions[actionName] = key
	else
		error("Key must be a string or table of strings!")
	end
	--print(actionName, key)
end

--- Shortcut to Input.addAction
function Input.rebindAction(actionName, newKey)
	return Input.addAction(actionName, newKey)
end

--- Removes an action from the actions table, making it unusable.
function Input.removeAction(actionName)
	Input.actions[actionName] = nil
end

--- Checks if an action exists in the actions table.
--- @return boolean true/false depending on the result.
function Input.hasAction(actionName)
	return Input.actions[actionName] ~= nil
end

function Input.getActionFromKey(key)
	local matches = {}
	for actionName, keys in pairs(Input.actions) do
		for i = 1, #keys do
			if key == keys[i] then
				table.insert(matches, actionName)
			end
		end
	end
	if #matches > 0 then return matches
	else return { UNKNOWN_ACTION } end
end

return Input
