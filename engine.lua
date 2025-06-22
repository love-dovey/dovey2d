--Overriding defaults--
require("dovey.util.tabletools")
require("dovey.util.stringtools")
require("dovey.util.mathtools")
--These must be imported first--
Enum = require("dovey.util.enum")
Tint = require("dovey.util.tint")
Log = require("dovey.util.log")
Object = require("dovey.object")
Rect2 = require("dovey.util.rect2")
Vec2 = require("dovey.util.vec2")
Timer = require("dovey.util.timer")
Signal = require("dovey.util.signal")
-- Objects --
Input = require("dovey.input")
Canvas = require("dovey.canvas")
AnimationPlayer = require("dovey.animation.animationPlayer")
TintRectangle = require("dovey.display.tintRectangle")
ProgressShape = require("dovey.display.progressShape")
Sprite = require("dovey.display.sprite")
TextDisplay = require("dovey.display.textDisplay")

local Engine = {
	_NAME = "dövey",
	_VERSION = "1.0.0",
	_DESCRIPTION = "Small extension for LÖVE2D",
	_URL = "https://github.com/love-dovey/dovey2d",
	_LICENSE = [[
		Copyright 2025 pisayesiwsi

		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]],
	activeCanvas = nil,
	layeredObjects = {},
	clearTint = { 0.1, 0.1, 0.1, 1 },
	maxFPS = 60,
	mainWindow = {
		x = 0, y = 0,
		width = 0, height = 0,
		flags = {},
		getPosition = function()
			return Engine.mainWindow.x, Engine.mainWindow.y
		end,
		setPosition = function(x, y)
			x, y = x or 0, y or 0
			Engine.mainWindow.x = x
			Engine.mainWindow.y = y
		end,
		getSize = function()
			return Engine.mainWindow.width, Engine.mainWindow.height
		end,
		setSize = function(w, h)
			Engine.mainWindow.width = w or 1
			Engine.mainWindow.height = h or 1
		end,
		setFlags = function(f)
			Engine.mainWindow.flags = f or {}
		end,
		reset = function()
			local w, h, f = love.window.getMode()
			Engine.mainWindow.setSize(w, h)
			Engine.mainWindow.setFlags(f)
			Engine.mainWindow.setPosition(love.window.getPosition())
		end
	},
}

function love.resize(w, h)
	Engine.mainWindow.reset()
end

function Engine.setClearTint(tint)
	Engine.clearTint = tint or { 0.1, 0.1, 0.1, 1 }
end

function Engine.getVersion()
	return Engine._NAME .. " " .. Engine._VERSION .. " (on LÖVE " .. love.getVersion() .. ")"
end

local function limitedRun()
	-- yeah, yeah we're doing this.
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
	if love.timer then love.timer.step() end
	local minDelta = 1 / Engine.maxFPS
	local nextTime = love.timer.getTime()
	local curDelta = 0
	while true do
		if love.timer and Engine.maxFPS > 0 then
			local curTime = love.timer.getTime()
			if nextTime < curTime - minDelta then
				nextTime = curTime
			end
			if nextTime > curTime then
				love.timer.sleep(nextTime - curTime)
			end
		end
		if love.event then
			love.event.pump()
			for e, a, b, c, d in love.event.poll() do
				if e == "quit" and (not love.quit or not love.quit()) then
					return a or 0
				end
				local handler = love.handlers[e]
				if handler then handler(e, a, b, c, d) end
			end
		end
		if love.timer then curDelta = love.timer.step() end
		if love.update then love.update(curDelta) end
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			--love.graphics.clear(Engine.clearTint)
			if love.draw then love.draw() end
			love.graphics.present()
		end
		nextTime = nextTime + minDelta
		if Engine.maxFPS <= 0 then
			love.timer.sleep(0.001)
		end
	end
end

function love.run() return limitedRun() end

function Engine.begin(startingCanvas)
	Engine.mainWindow.reset()

	Engine.loveVer = tostring(love.getVersion())
	love.update = function(delta)
		if Engine.activeCanvas then Engine.activeCanvas:update(delta) end
		for _, v in pairs(Engine.layeredObjects) do
			if v and v.update then
				-- Closures (or just normal tables) can also update.
				if getmetatable(v) then
					v:update(delta)
				else
					v.update(delta)
				end
			end
		end
		Timer.updateAll(delta)
		Input.update(delta)
	end
	love.draw = function()
		love.graphics.clear(Engine.clearTint)
		if Engine.activeCanvas then Engine.activeCanvas:draw() end
		for _, v in pairs(Engine.layeredObjects) do
			if v and v.draw then
				-- Closures (or just normal tables) can also draw.
				if getmetatable(v) then
					v:draw()
				else
					v.draw()
				end
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
		error("Unable to switch to Canvas " .. tostring(input) .. ", make sure it's a table.")
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
	for k, v in pairs(_layerIndexes) do
		if _layerIndexes[i] > -1 then
			table.remove(Engine.layeredObjects, i)
		end
	end
end

local function traceback(msg) -- I was having issues with LÖVE12 and debug.traceback so this will have to work.
	msg = tostring(msg or "")
	if love.getVersion() >= 12 then
		return debug.traceback(msg)
	end
	local level = 2
	local tb = msg
	while true do
		local info = debug.getinfo(level, "S1")
		if not info then break end
		tb = tb .. "\n" .. string.format("%s:%d", info.short_src, info.currentline)
		level = level + 1
	end
	if not tb or #tb == 0 then return "(stack trace unavailable)" end
	return tb
end

function Engine.errorhandler(msg)
	msg = tostring(msg) -- make sure its a string
	print(traceback("Error: " .. msg .. "\n"))
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
		for i, v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.origin()

	local stack = traceback()
	local width, height = love.graphics.getDimensions()

	return function()
		love.event.pump()
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			end
		end
		love.graphics.clear(0.2, 0.2, 0.2, 1)

		love.graphics.push("all")

		-- draw error screen --
		love.graphics.setColor(0.1, 0.1, 0.5, 0.8)
		love.graphics.rectangle("fill", 0, 0, width, height)

		-- fancy line around screen
		love.graphics.setLineWidth(3)
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.rectangle("line", 5, 5, width - 10, height - 10)

		-- header
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(love.graphics.newFont(24))
		love.graphics.printf("[ Crash Report ]", 0, 5, width - 10, "center")
		-- error
		love.graphics.setFont(love.graphics.newFont(16))
		love.graphics.printf(msg, 50, 15 + 24, width - 10, "left")
		-- stack
		love.graphics.printf(tostring(stack), 50, height / 8, width - 10, "left")

		-- instructions
		love.graphics.printf("\n\nPress ESCAPE to close", 0, height - 80, width - 10, "center")

		love.graphics.present()
		love.graphics.pop()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end

return Engine
