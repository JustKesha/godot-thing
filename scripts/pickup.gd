class_name Pickup extends Interactable

@export var item_name := 'matches'
@export var quantity := 1

func interact(player: PlayerAPI):
	player.inventory.add(item_name, quantity)
	queue_free()
