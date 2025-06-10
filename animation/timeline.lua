local DEFAULT_FRAMERATE = 30
local Timeline = Proto:extend({
	name = "Timeline",
	tracks = {}, --- Tracks for modifying values (e.g. Position, Angle, Scale, Tint, etc.).
	frameRate = DEFAULT_FRAMERATE, --- Update frequency.
	finished = false, --- Animation is done.
	paused = false, --- Animation is paused.
	time = 0.0, --- Self-explanatory, yeah?
	speed = 1.0, --- How fast/slow the animation plays.
	length = 0, --- Duration in seconds.
})
function Timeline:__tostring()
	return ("Timeline(Animation: %s, FPS: %i)"):format(self.name, tostring(self.frameRate))
end

function Timeline:init(name, tracks, frameRate, length)
	self.name = name
	self.tracks = tracks or {}
	self.frameRate = frameRate or DEFAULT_FRAMERATE
	self.length = length or 1
	return self
end

function Timeline:update(delta)
	if self.paused or self.finished then return end
	if not self.tracks then return end
	self.time = math.min(self.time + delta * (self.speed or 1.0), self.length)
	for index, track in ipairs(self.tracks) do
		local frame = math.floor(self.time * self.frameRate + 0.5) + 1
		local fireCallback = false
		if not track.values then
			fireCallback = true
		else
			local value = track.values[frame]
			if value ~= nil then
				if track.setter then
					track.setter(value)
				else
					track.target[track.property] = value
				end
			else
				if track.callback then
					track.callback()
				end
			end
		end
		if fireCallback and track.callback then
			track.callback()
		end
	end
	if self.time >= self.length then
		self.time = self.length
		self.finished = true
		--self.signals.finished.emit(self) -- I'll do it later ok.
	end
end

return Timeline
