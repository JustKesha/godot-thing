class_name Pickup extends Interactable

@export var item_name := 'matches'
@export var quantity := 1
@export var allow_overflow := false

func interact(player: PlayerAPI):
	var overflow := player.inventory.add(item_name, quantity)
	
	if overflow == 0 or allow_overflow:
		queue_free()
	else:
		quantity = overflow
