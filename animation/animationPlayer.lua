local Timeline = require("dovey.animation.timeline")
local AnimationPlayer = Proto:extend({
	currentAnimation = nil,
	animations = {},
})
local _latestAnimation = nil

function AnimationPlayer:init()
	return self
end

function AnimationPlayer:update(delta)
	if self.currentAnimation then
		self.currentAnimation:update(delta)
	end
end

function AnimationPlayer:addAnimation(name, tracks, frameRate, length)
	self.animations[name] = Timeline:new(name, tracks, frameRate, length)
end

function AnimationPlayer:findAnimation(name)
	return self.animations[name]
end

function AnimationPlayer:play(name, speed, force)
	local anim = self:findAnimation(name)
	if not anim then
		Log.warn("Animation \""..tostring(name).."\" doesn't exist!")
		return
	end
	anim.speed = speed or anim.speed
	self.currentAnimation = anim
	if force or _latestAnimation ~= name then
		self:seek(0.0)
	end
	_latestAnimation = name
end

function AnimationPlayer:seek(time)
	if not self.currentAnimation then
		Log.warn("Tried to seek(), but no animation is set.")
		return
	end
	self.currentAnimation.time = time or 0.0
	self.currentAnimation.finished = false
end

function AnimationPlayer:pause()
	if not self.currentAnimation then
		Log.warn("Tried to pause(), but no animation is set.")
		return
	end
	self.currentAnimation.paused = true
end

function AnimationPlayer:resume()
	if not self.currentAnimation then
		Log.warn("Tried to resume(), but no animation is set.")
		return
	end
	self.currentAnimation.paused = false
end

return AnimationPlayer