extends Item

func _use():
	player.lantern.fuel += 5
