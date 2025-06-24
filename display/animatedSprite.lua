local AnimatedSprite = require("dovey.animation.animation")
local Caps2D = require("dovey.caps.caps2d")

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
		offset = DEFAULT_FRAME_OFFSET,        --- Frame offset (important for some formats).
	}
end

--- Much like `Sprite`, but contains frames to play animations instead.
--- @class AnimatedSprite
local AnimatedSprite = Sprite:extend {
	_name = "AnimatedSprite",
	frame = 1,
	animations = {},
	texture = nil
}

local _latestAnimation = ""

function AnimatedSprite:init(x, y, texture)
	self.position = Vec2(x or self.position.x, y or self.position.y)
	return self
end

function AnimatedSprite:update(delta)
	local anim = self.currentAnimation
	if anim and not anim.paused and not anim.finished then
		anim.time = math.min(anim.time + delta * (anim.speed or 1.0), anim.length)
		if anim.time >= anim.length then
			-- I need it to loop for now.
			anim.time = 0.0
			--anim.finished = true
		end
		self.frame = math.min(math.floor(anim.time * anim.frameRate + 0.5) + 1, #anim.quads)
	end
end

function AnimatedSprite:draw()
	love.graphics.push("all")

	local quad = nil
	local curAnim = self.currentAnimation
	local tex = self.texture
	local offx, offy = 0, 0
	local scalx, scaly = 1, 1
	local rot = 0

	if curAnim and #curAnim.quads ~= 0 then
		local frame = curAnim.quads[self.frame]
		if frame then
			if frame.texture then -- quad specific textures
				tex = curAnim.quads[self.frame].texture
			end
			quad = frame.quad
			local frameOffset = frame.offset or DEFAULT_FRAME_OFFSET
			offx, offy = -frameOffset.x, -frameOffset.y
			if frame.scale then
				scalx, scaly = frame.scale.x, frame.scale.y
			end
			rot = frameOffset.r or 0
		end
	end

	love.graphics.translate(self.position.x, self.position.y)    -- Positioning
	love.graphics.rotate(self.rotation + rot)                    -- Rotation
	love.graphics.shear(self.shear.x, self.shear.y)              -- Skewing
	love.graphics.scale(self.scale.x * scalx, self.scale.y * scaly) -- Scale
	love.graphics.translate(-self.origin.x, -self.origin.y)      -- Pivot Offset
	love.graphics.setColor(self.tint)                            -- Colouring

	if tex then
		if quad then
			love.graphics.translate(offx, offy) -- Frame Offset
			love.graphics.draw(tex, quad)
		else
			love.graphics.draw(tex)
		end
	end

	love.graphics.pop()
end

function AnimatedSprite:addAnimation(name, quads, frameRate, texture, length)
	local animation = makeAnimation(name, texture, frameRate, length)
	if type(quads) ~= "table" then
		-- probably single frame.
		animation.quads = { quads }
	else
		for i = 1, #quads do animation.quads[i] = quads[i] end
	end
	self.animations[name] = animation
end

function AnimatedSprite:findAnimation(name)
	return self.animations[name]
end

function AnimatedSprite:play(name, speed, force)
	local anim = self:findAnimation(name)
	if not anim then
		Log.warn("Animation \"" .. tostring(name) .. "\" doesn't exist!")
		return
	end
	anim.speed = speed or anim.speed
	self.currentAnimation = anim
	if force or _latestAnimation ~= name then
		self:seek(0.0)
	end
	_latestAnimation = name
end

function AnimatedSprite:seek(time)
	if not self.currentAnimation then
		Log.warn("Tried to seek(), but no animation is set.")
		return
	end
	self.currentAnimation.time = time or 0.0
	self.currentAnimation.finished = false
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
