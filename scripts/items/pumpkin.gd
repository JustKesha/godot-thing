extends Item

@export var fuel_gain: float = 15.0

func _on_use():
	if player.lantern.fuel == player.lantern.fuel_limit:
		return false
	player.lantern.fuel += fuel_gain
	return true
