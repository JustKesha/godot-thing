class_name InteractableRestPoint extends Interactable

@export var fuel_gain := 100.0

func interact(player: PlayerAPI):
	player.lantern.fuel += fuel_gain
	player.dialogue_window.display([
		"Sweet rest.",
		"Finally, I can catch my breath.",
		"I can rest for a bit.",
	].pick_random())
	$Light.is_lit = false
	
	remove()

func _on_interactable_ready():
	info_title = "Resting Place"
	info_desc = "Save energy for the road"
