class_name SoulDice extends Dice

@onready var lantern: PlayerLantern = References.player.lantern
@export var rewards: Array[float] = [-100, -60, 0, 30, 75, 125]

func _on_roll_finished():
	var reward = rewards[score-1]
	
	lantern.fuel += reward
	
	if reward > 0:
		particles.spawn(body.global_position, particles.Particles.SPARK, body)
	
	match score:
		1: lantern.extinguish()
		4,5,6: lantern.reignite()
