local AnimatedSprite = require("dovey.animation.animation")
local Caps2D = require("dovey.caps.caps2d")
local Signal = require("dovey.util.signal")

--- Default Animation Framerate.
--- @type number
local DEFAULT_FRAMERATE = 30
local DEFAULT_FRAME_OFFSET = { x = 0, y = 0, w = 0, h = 0, r = 0 }

--local QUAD_EXAMPLE = {
--	quad = love.graphics.newQuad(x, y, width, height, textureWidth, textureHeight),
--	size = { modifiedWidth, modifiedHeight }, -- optional
--	offset = { x = x, y = y, w = width, h = height, r = rotationAngle },
--	scale = { x = scaleX, y = scaleY },
--}

local function makeAnimation(name, texture, frameRate, length)
	return {
		name = name,
		texture = texture or nil,
		frameRate = frameRate or DEFAULT_FRAMERATE, --- Update frequency.
		length = length or 1.0,               --- Duration in seconds.
		finished = false,                     --- Animation is done.
		paused = false,                       --- Animation is paused.
		time = 0.0,                           --- Self-explanatory, yeah?
		speed = 1.0,                          --- How fast/slow the animation plays.
		quads = {},                           --- Animation quad info (render frames),
		frameOffset = DEFAULT_FRAME_OFFSET,   --- Frame offset (important for some formats).
		offset = { x = 0, y = 0 },            --- Position Offset.
		getCurrentFrameDuration = function(self)
			return 1 / self.frameRate
		end,
		animationLooped = Signal:new(),
		animationFinished = Signal:new(),
		looped = false,
		loopPoint = 1,
		frame = 1,
	}
end

--- Much like `Sprite`, but contains frames to play animations instead.
--- @class AnimatedSprite
local AnimatedSprite, super = dovey.display.Sprite:extend {
	_name = "AnimatedSprite",
	_latestAnimation = "",
	animations = {},
	texture = nil,
}:implement(Caps2D)

function AnimatedSprite:init(x, y, texture)
	self.position = dovey.math.Vec2(x or self.position.x, y or self.position.y)
	if texture then self:loadTexture(texture) end
	return self
end

function AnimatedSprite:update(delta)
	local anim = self.currentAnimation
	if not anim or anim.paused or anim.finished then return end

	anim.time = (anim.time or 0) + delta * (anim.speed or 1.0)

	local frameDur = anim:getCurrentFrameDuration()
	while anim.time > frameDur and not anim.finished do
		anim.time = anim.time - frameDur

		if anim.reversed then
			if anim.looped and anim.frame == (anim.loopPoint or 1) then
				anim.frame = #anim.quads
				if anim.animationLooped then anim.animationLooped:emit(anim.name) end
			else
				anim.frame = anim.frame - 1
			end
		else
			if anim.looped and anim.frame == #anim.quads then
				anim.frame = anim.loopPoint or 1
				if anim.animationLooped then anim.animationLooped:emit(anim.name) end
			else
				anim.frame = anim.frame + 1
			end
		end

		if not anim.looped then
			if anim.frame < 1 then
				anim.frame = 1
				anim.finished = true
				if anim.animationFinished then anim.animationFinished:emit(anim.name) end
			elseif anim.frame > #anim.quads then
				anim.frame = #anim.quads
				anim.finished = true
				if anim.animationFinished then anim.animationFinished:emit(anim.name) end
			end
		end

		if not anim.finished then
			frameDur = anim:getCurrentFrameDuration()
		end
	end
end

function AnimatedSprite:dispose()
	for i = 1, #self.animations do
		local anim = self.animations[i]
		if anim.animationFinished then anim.animationFinished:dispose() end
		if anim.animationLooped then anim.animationLooped:dispose() end
		if anim.texture and anim.texture.release then dovey.Assets.releaseResource(anim.texture) end
		-- beating a dead horse:
		anim.animationFinished = nil
		anim.animationLooped = nil
		anim.texture = nil
		anim = nil
	end
	self.texture = dovey.Assets.releaseResource(self.texture)
	self.texture = nil
end

function AnimatedSprite:getDimensions()
	local w, h = 1, 1
	if self.texture then
		w, h = self.texture:getDimensions()
	end
	return w, h
end

local function applyDirectionalOffset(off, scal, flip)
	return off * ((scal >= 0) and 1 or -1) * (flip and -1 or 1)
end

function AnimatedSprite:draw()
	love.graphics.push("all")

	local quad = nil
	local tex = self.texture
	local curAnim = self.currentAnimation
	local frameW, frameH = self:getDimensions()
	local frameX, frameY = 0, 0
	local frameScalX, frameScalY = 1, 1
	local offx, offy = 0, 0
	local rot = 0

	if curAnim and #curAnim.quads ~= 0 then
		local frame = curAnim.quads[curAnim.frame]
		if frame then
			if frame.texture then -- quad specific textures
				tex = frame.texture
			end
			quad = frame.quad
			if quad then
				local _, _, w, h = quad:getViewport()
				frameW, frameH = w, h
			end

			local frameOffset = frame.frameOffset or DEFAULT_FRAME_OFFSET
			if frame.scale then
				frameScalX, frameScalY = frame.scale.x, frame.scale.y
			end
			frameX = applyDirectionalOffset(frameOffset.x or 0, self.scale.x, frameScalX < 0)
			frameY = applyDirectionalOffset(frameOffset.y or 0, self.scale.y, frameScalY < 0)
			rot = frameOffset.r or 0
		end
		offx, offy = curAnim.offset.x or 0, curAnim.offset.y or 0
	end

	local px, py = self.position.x + offx, self.position.y + offy
	love.graphics.translate(px, py)                                        			 -- Positioning
	love.graphics.rotate(self.rotation + rot)                              			 -- Rotation
	love.graphics.scale(self.scale.x * frameScalX, self.scale.y * frameScalY)        -- Scale
	love.graphics.shear(self.shear.x, self.shear.y)                        			 -- Skewing

	local marginX, marginY = self:getMarginOffset(self.margin, frameW, frameH)
	love.graphics.translate(
		-(marginX + self.origin.x) - frameX,
		-(marginY + self.origin.y) - frameY
	) -- Pivot + Frame Offset
	love.graphics.setColor(self.tint)                                      -- Colouring

	if tex then
		if quad then
			love.graphics.draw(tex, quad)
		else
			love.graphics.draw(tex)
		end
	end

	love.graphics.pop()
end

function AnimatedSprite:addAnimation(name, quads, frameRate, length)
	local tex = self.texture
	if quads.texture and quads.texture:type() == "Texture" then
		tex = quads.texture
	end
	local animation = makeAnimation(name, tex, frameRate, length)
	if type(quads) ~= "table" then
		-- probably single frame.
		animation.quads = { quads }
	else
		for i = 1, #quads do animation.quads[i] = quads[i] end
	end
	self.animations[name] = animation
	self:setAnimationOffset(name, 0, 0)
	return self
end

function AnimatedSprite:setAnimationOffset(name, x, y)
	if self.animations[name] then
		self.animations[name].offset.x = x or self.animations[name].offset.x or 0
		self.animations[name].offset.y = y or self.animations[name].offset.y or 0
	else
		Log.warn("Cannot add offset to Animation(" .. tostring(name) .. "), Animation does not exist.")
	end
end

function AnimatedSprite:findAnimation(name)
	return self.animations[name]
end

function AnimatedSprite:play(name, force, speed, reverse)
	local anim = self:findAnimation(name)
	if not anim then
		Log.warn("Animation \"" .. tostring(name) .. "\" doesn't exist!")
		return
	end
	self.currentAnimation = anim
	anim.speed = type(reverse) == "number" and speed or (anim.speed or 1.0)
	anim.reverse = type(reverse) == "boolean" and reverse or false
	if force or self._latestAnimation ~= name or self.currentAnimation.finished then
		self:seek(0.0)
	end
	self._latestAnimation = name
end

function AnimatedSprite:seek(time)
	if not self.currentAnimation then
		Log.warn("Tried to seek(), but no animation is set.")
		return
	end
	local curAnim = self.currentAnimation
	curAnim.time = time or 0.0
	curAnim.finished = false
	curAnim.frame = curAnim.loopPoint
end

-- returns the current animation.
function AnimatedSprite:peek()
	return self.currentAnimation
end

function AnimatedSprite:pause()
	if not self.currentAnimation then
		Log.warn("Tried to pause(), but no animation is set.")
		return
	end
	self.currentAnimation.paused = true
end

function AnimatedSprite:resume()
	if not self.currentAnimation then
		Log.warn("Tried to resume(), but no animation is set.")
		return
	end
	self.currentAnimation.paused = false
end

return AnimatedSprite
