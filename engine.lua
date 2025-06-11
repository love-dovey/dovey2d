--Overriding defaults--
function table.copy(tbl)
	local copy = {}
	for k, v in ipairs(tbl) do
		copy[k] = v
	end
	return copy
end
function string.tablestring(tbl)
	local str = "\n"
	local function continuestr(k, v)
		return str.."	"..tostring(k).."="..tostring(v)..",\n"
	end
	for k,v in pairs(tbl or {}) do
		if v == nil then return end
		str = continuestr(k,v)
	end
	return tostring(tbl).." {"..str.."}\n"
end
--These must be imported first--
Enum = require("dovey.util.enum")
Tint = require("dovey.util.tint")
Log = require("dovey.util.log")
Rect2 = require("dovey.util.rect2")
Vec2 = require("dovey.util.vec2")
Proto = require("dovey.proto")
-- Objects --
Input = require("dovey.input")
Canvas = require("dovey.canvas")
Signal = require("dovey.util.signal")
TintRectangle = require("dovey.display.tintRectangle")
AnimationPlayer = require("dovey.animation.animationPlayer")
Sprite = require("dovey.display.sprite")

local Engine = {
	activeCanvas = nil,
	layeredObjects = {},
	clearTint = {0.1, 0.1, 0.1, 1},
	enginName = "dövey",
	version = "1.0.0",
	maxFPS = 60,
}

function Engine.setClearTint(tint)
	Engine.clearTint = tint or {0.1, 0.1, 0.1, 1}
end

function Engine.getVersion()
	local i = Engine.info()
	return i.engineName.." "..i.verName.." (on LÖVE "..i.loveVer..")"
end

function Engine.info()
	return {
		engineName = Engine.engineName or "dövey",
		verName = tostring(Engine.version),
		loveVer = tostring(love.getVersion()),
	}
end

function Engine.begin(startingCanvas)
	love.update = function(delta)
		if Engine.activeCanvas then Engine.activeCanvas:update(delta) end
		for _, v in pairs(Engine.layeredObjects) do
			if v and v.update then
				-- Closures (or just normal tables) can also update.
				if getmetatable(v) then v:update(delta)
				else v.update(delta) end
			end
		end
		Input.update(delta)
	end
	love.draw = function()
		love.graphics.clear(Engine.clearTint)
		if Engine.activeCanvas then Engine.activeCanvas:draw() end
		for _, v in pairs(Engine.layeredObjects) do
			if v and v.draw then
				-- Closures (or just normal tables) can also draw.
				if getmetatable(v) then v:draw()
				else v.draw() end
			end
		end
	end
	love.errorhandler = function(msg)
		return Engine.errorhandler(msg)
	end
	if startingCanvas then
		Engine.changeCanvas(startingCanvas)
	end
end

local function _makeCanvas(input)
	local ___ = input
	if type(input) == "string" then ___ = require(input) end
	--elseif Canvas:is(next) then ___ = next end
	if type(___) ~= "table" then
		error("Unable to switch to Canvas "..tostring(input)..", make sure it's a table.")
		return
	end
	if ___ and ___.new then
		return ___:new()
	end
	return nil
end

function Engine.changeCanvas(next)
	-- emit a signal before the previous canvas gets deleted and after we switch to a new one.
	Engine.activeCanvas = _makeCanvas(next)
end

local _layerIndexes = {}

function Engine.addLayered(object)
	local v = object
	local isTbl = type(object) == "table"
	--if isTbl then
	--	print("metatable? "..tostring(getmetatable(v) ~= nil))
	--end
	if type(v) == "string" or isTbl then
		-- for metatables specifically.
		if isTbl and getmetatable(v) then
			v = _makeCanvas(object)
		end
	end
	table.insert(Engine.layeredObjects, v)
	_layerIndexes[#Engine.layeredObjects] = #Engine.layeredObjects
end

function Engine.removeLayered(object)
	for k,v in pairs(_layerIndexes) do
		if _layerIndexes[i] > -1 then
			table.remove(Engine.layeredObjects, i)
		end
	end
end

function Engine.errorhandler(msg)
	msg = tostring(msg) -- make sure its a string
	print(debug.traceback("Error: "..msg.."\n"):gsub("\n[^\n]+$", ""))
	if not love.window or not love.graphics or not love.event then
		return
	end
	-- open emergency window (if the main one is somehow not present)
	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then return end
	end
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local fonts = {
		error = love.graphics.newFont("resources/test.ttf", 20),
		emoticon = love.graphics.newFont("resources/test.ttf", 64),
		default = love.graphics.getFont(),
	}
	love.graphics.setColor(1,1,1,1)
	local stack = debug.traceback()
	love.graphics.origin()
	return function()
		love.event.pump()
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			end
		end
		love.graphics.push("all")
		love.graphics.clear(love.math.colorFromBytes(15,15,15,255))

		love.graphics.setFont(fonts.emoticon)
		love.graphics.print("Oh!",5,5)

		love.graphics.setFont(fonts.error)
		love.graphics.print((
			msg.."\nThis is an error, please report!\n\n"..
			tostring(stack).."\n\nPress ESCAPE to close"),
		5,100)

		love.graphics.present()
		love.graphics.setFont(fonts.default)
		love.graphics.pop()
		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end

return Engine
