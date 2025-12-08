class_name InteractableRestPoint extends Interactable

@export var fuel_gain := 100.0

func _on_interact():
	player.lantern.fuel += fuel_gain
	$Light.is_lit = false
	remove()
