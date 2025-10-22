class_name InteractableRestPoint extends Interactable

var is_used := false

func interact(player: PlayerAPI):
	if is_used: return
	player.lantern.fuel += 25
	$Light.is_lit = false
	is_used = true
