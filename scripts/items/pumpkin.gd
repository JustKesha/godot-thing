extends Item

func _use():
	player.lantern.fuel += 15
	player.dialogue_window.display([
		"Tastes gross...",
		"That was not tasty...",
		"Yuck!",
		"Ew!"
	].pick_random())
	return true
