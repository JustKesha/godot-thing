extends Item

@export var effect_id: String = "satiety"
@export var effect_duration: float = 5.0

func _on_use():
	player.effects.apply(effect_id, effect_duration)
	return true
