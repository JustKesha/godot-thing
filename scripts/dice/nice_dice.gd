class_name NiceDice extends Dice

@export var fuel_rewards: Array[float] = [-100, -50, -10, 20, 30, 50]

func _on_roll_finished(score: int):
	var lantern := References.player_api.lantern
	var reward := fuel_rewards[score-1] if (score >= 1 and score <= 6) else 0.0
	
	lantern.fuel += reward
	
	match score:
		1: lantern.extinguish()
		6: lantern.reignite()
