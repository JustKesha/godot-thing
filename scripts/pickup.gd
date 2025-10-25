class_name Pickup extends Interactable

@export var item_name := 'candle'
@export var quantity := 1
@export var pickup_rate := 99
@export var allow_overflow := false

func interact(player: PlayerAPI):
	var overflow := 0
	var pickup_amount := 0
	
	if pickup_rate > quantity:
		pickup_amount = quantity
	else:
		pickup_amount = pickup_rate
		overflow += quantity - pickup_amount
	
	overflow += player.inventory.add(item_name, pickup_amount)
	
	if overflow == 0 or allow_overflow:
		remove()
	else:
		quantity = overflow

func remove():
	queue_free()
