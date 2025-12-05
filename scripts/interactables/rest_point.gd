class_name InteractableRestPoint extends Interactable

@onready var player: PlayerAPI = References.player
@export var fuel_gain := 100.0

func _on_interact():
	player.lantern.fuel += fuel_gain
	player.dialogue_window.display([
		"Sweet rest.",
		"Finally, I can catch my breath.",
		"I can rest for a bit.",
	].pick_random())
	$Light.is_lit = false
	
	remove()
