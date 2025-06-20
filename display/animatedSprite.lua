local AnimationPlayer = require("dovey.animation.animationPlayer")

local AnimatedSprite = Sprite:extend({
	animation = AnimationPlayer:new()
})

return AnimatedSprite