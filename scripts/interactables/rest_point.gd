class_name InteractableRestPoint extends Interactable

@export var fuel_gain := 25.0

var is_used := false

func interact(player: PlayerAPI):
	if is_used: return
	
	player.lantern.fuel += fuel_gain
	player.inventory.add('matches', 4)
	$Light.is_lit = false
	
	is_used = true
