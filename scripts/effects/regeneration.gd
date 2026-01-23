extends Effect

func _on_tick(tps: float):
	player.lantern.fuel += stack/tps
