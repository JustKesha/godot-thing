class_name InteractableRestPoint extends Interactable

@export var fuel_gain := 25.0

var is_used := false

func interact(player: PlayerAPI):
	if is_used: return
	
	player.lantern.fuel += fuel_gain
	player.dialogue_window.display([
		"Sweet rest.",
		"Finally, I can catch my breath.",
		"I can rest for a bit.",
	].pick_random())
	$Light.is_lit = false
	
	is_used = true
