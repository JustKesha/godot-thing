extends Item

func _use():
	if player.lantern.light.is_lit:
		player.dialogue_window.display([
			"There's no need for that now.",
			"I don't need those right now.",
			"I will need them when I'm out of light.",
			"Later."
		].pick_random())
		return false
	
	if player.lantern.fuel < 5: player.lantern.fuel = 5
	player.lantern.reignite()
	player.dialogue_window.display([
		"Back in the light!",
		"My light is back!",
		"The saving light!",
		"Thank god!"
	].pick_random())
	return true
