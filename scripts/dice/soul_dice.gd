class_name SoulDice extends Dice

@onready var lantern: PlayerLantern = References.player.lantern
@export var fuel_rewards: Array[float] = [-100, -60, 0, 30, 75, 125]

func _on_roll_finished():
	lantern.fuel += fuel_rewards[score-1]
	match score:
		1: lantern.extinguish()
		4,5,6: lantern.reignite()
