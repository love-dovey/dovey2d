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
		frameOffset = DEFAULT_FRAME_OFFSET,   --- Frame offset (important for some formats).
		offset = { x = 0, y = 0 },            --- Position Offset.
	}
end

--- Much like `Sprite`, but contains frames to play animations instead.
--- @class AnimatedSprite
local AnimatedSprite, super = dovey.display.Sprite:extend {
	_name = "AnimatedSprite",
	frame = 1,
	animations = {},
	texture = nil
}:implement(Caps2D)

local _latestAnimation = ""

function AnimatedSprite:init(x, y, texture)
	self.position = dovey.math.Vec2(x or self.position.x, y or self.position.y)
	if texture then self:loadTexture(texture) end
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

local function applyDirectionalOffset(off, scal, flip)
	return off * ((scal >= 0) and 1 or -1) * (flip and -1 or 1)
end

function AnimatedSprite:draw()
	love.graphics.push("all")

	local quad = nil
	local tex = self.texture
	local curAnim = self.currentAnimation
	local framex, framey = 0, 0
	local scalx, scaly = 1, 1
	local offx, offy = 0, 0
	local rot = 0

	if curAnim and #curAnim.quads ~= 0 then
		local frame = curAnim.quads[self.frame]
		if frame then
			if frame.texture then -- quad specific textures
				tex = curAnim.quads[self.frame].texture
			end
			quad = frame.quad

			local frameOffset = frame.frameOffset or DEFAULT_FRAME_OFFSET
			if frame.scale then
				scalx, scaly = frame.scale.x, frame.scale.y
			end
			framex = applyDirectionalOffset(frameOffset.x or 0, self.scale.x, scalx < 0)
			framey = applyDirectionalOffset(frameOffset.y or 0, self.scale.y, scaly < 0)
			rot = frameOffset.r or 0
		end
		offx, offy = curAnim.offset.x or 0, curAnim.offset.y or 0
	end

	local px, py = self.position.x + offx, self.position.y + offy
	love.graphics.translate(px, py)                                        -- Positioning
	love.graphics.rotate(self.rotation + rot)                              -- Rotation
	love.graphics.shear(self.shear.x, self.shear.y)                        -- Skewing
	love.graphics.scale(self.scale.x * scalx, self.scale.y * scaly)        -- Scale
	love.graphics.translate(-self.origin.x - framex, -self.origin.y - framey) -- Pivot + Frame Offset
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
