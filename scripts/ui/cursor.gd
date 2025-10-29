class_name PlayerCursor extends Control

enum States { HIDDEN = -1, INSPECT = 0 }

@export var sprite: AnimatedSprite2D
@export var animations := [
	"INSPECT",
]

@export var state := States.HIDDEN:
	set(value):
		state = value
		if state < 0:
			self.visible = false
		else:
			self.visible = true
			sprite.play(animations[state])
