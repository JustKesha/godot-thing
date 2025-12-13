class_name Pickup extends Interactable

@export var pickup_item := 'candle'
@export var pickup_quantity := 1
@export var pickup_rate := 99
@export var pickup_allow_overflow := false

func _on_remove():
	particles.spawn(self.global_position + Vector3.UP * .1,
		particles.Particles.POOF)

func _on_interact():
	var overflow := 0
	var pickup_amount := 0
	
	if pickup_rate > pickup_quantity:
		pickup_amount = pickup_quantity
	else:
		pickup_amount = pickup_rate
		overflow += pickup_quantity - pickup_amount
	
	overflow += player.inventory.add(pickup_item, pickup_amount)
	
	if overflow == 0 or pickup_allow_overflow:
		remove()
	else:
		pickup_quantity = overflow
