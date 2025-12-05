class_name PlayerCursor extends Control

enum Cursor { HIDDEN = -1, INSPECT = 0 }
@export var sprite: AnimatedSprite2D
@export var tooltip: PlayerInteractionTooltip
@export var animations := [
	"INSPECT",
	]

var state := Cursor.HIDDEN:
	set(value):
		state = value
		if state < 0:
			self.visible = false
			sprite.stop()
		else:
			self.visible = true
			if state < len(animations):
				sprite.play(animations[state])

func set_state(cursor: Cursor): state = cursor
func set_tooltip(title: String = '', desc: String = '', action: String = '',
	key: String = ''): tooltip.set_info(title, desc, action, key)
