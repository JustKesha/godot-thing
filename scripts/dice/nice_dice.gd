class_name SoulDice extends Dice

@onready var lantern: PlayerLantern = References.player.lantern
@export var fuel_rewards: Array[float] = [-100, -50, -15, 30, 75, 135]

func _on_roll_finished():
	var reward := fuel_rewards[score-1] if (score >= 1 and score <= 6) else 0.0
	
	lantern.fuel += reward
	
	match score:
		1: lantern.extinguish()
		6: lantern.reignite()
