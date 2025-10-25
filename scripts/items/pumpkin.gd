extends Item

func _init():
	tag = "Yuck"

func _use():
	player.lantern.fuel += 15
	player.dialogue_window.display([
		"Tastes gross",
		"I dont like pumpkins",
		"Yuck",
		"Ew"
	].pick_random())
	return true
