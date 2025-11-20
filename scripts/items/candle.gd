extends Item

@export var min_fuel: float = 2.5

func _on_use():
	if player.lantern.light.is_lit:
		return false
	player.lantern.fuel = clamp(player.lantern.fuel, min_fuel, INF)
	player.lantern.reignite()
	return true
