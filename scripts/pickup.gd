class_name Pickup extends Interactable

@export var item_name := 'matches'
@export var quantity := 1

func interact(player: PlayerAPI):
	var overflow := player.inventory.add(item_name, quantity)
	
	if overflow == 0:
		queue_free()
	else:
		quantity = overflow
