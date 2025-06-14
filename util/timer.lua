--- Simple Timer class, counts from a specific duration to 0 and finishes
--- @class Timer
local Timer = Proto:extend({_name = "Timer"})
local _running = {}

function Timer:init()
	self.duration = 0
	self.loops = 0
	self.callbacks = {
		start = nil,
		update = nil,
		finish = nil,
		loop = nil,
	}
	self.finished = false
	self.progress = 0
	self._timeSpent = 0
	return self
end

--- Immediately stops the timer
function Timer:stop()
	if self.finished then return end
	self.finished = true
	_running[self] = nil
	if type(self.callbacks.finish) == "function" then
		self.callbacks.finish(self)
	end
end

--- Pauses the timer
function Timer:pause()
	_running[self] = nil
end

--- Resumes a paused timer
function Timer:resume()
	if not self.finished then
		_running[self] = true
	end
end

--- Resets the timer to initial state
function Timer:reset()
	self._timeSpent = 0
	self.progress = 0
	self.finished = false
end

function Timer:update(dt)
	if self.finished then return end

	self._timeSpent = self._timeSpent + dt
	self.progress = math.min(self._timeSpent / self.duration, 1)

	if type(self.callbacks.update) == "function" then
		self.callbacks.update(self)
	end

	if self.progress >= 1 then
		-- Loop callback
		if type(self.callbacks.loop) == "function" then
			self.callbacks.loop(self)
		end
		if self.loops > 0 then
			self.loops = self.loops - 1
			self:reset()
		else
			self:stop()
		end
	end
end

--- Starts the timer
--- @param duration number Timer duration in seconds
--- @param callbacks table|function Callbacks table or finish callback
--- @param loops number? Number of loops (0 = infinite)
function Timer:start(duration, callbacks, loops)
	assert(type(duration) == "number" and duration > 0, "Invalid duration")
	self:reset()
	self.duration = duration
	self.loops = loops or 0
	if type(callbacks) == "function" then
		self.callbacks.finish = callbacks
	elseif type(callbacks) == "table" then
		for name, cb in pairs(callbacks) do
			if self.callbacks[name] and type(cb) == "function" then
				self.callbacks[name] = cb
			end
		end
	end
	if type(self.callbacks.start) == "function" then
		self.callbacks.start(self)
	end
	_running[self] = true
	return self
end

--- Updates all active timers
--- @param delta number Delta time in seconds
function Timer.updateAll(delta)
	for timer in pairs(_running) do
		timer:update(delta)
	end
end

--- Creates and starts a new timer
function Timer.create(duration, callbacks, loops)
	return Timer:new():start(duration, callbacks, loops)
end

return Timer
