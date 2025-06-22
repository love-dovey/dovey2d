local AnimationPlayer = require("dovey.animation.animationPlayer")

--- Much like `Sprite`, but contains frames to play animations instead.
--- @class AnimatedSprite
local AnimatedSprite = Sprite:extend({
	animation = AnimationPlayer:new()
})

return AnimatedSprite