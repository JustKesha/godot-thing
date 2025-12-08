extends Item

@export var dice_scene: PackedScene
@export var player_offset: Vector3 = Vector3(0,3.0,-1.25)

func _on_use() -> bool:
	var dice: Dice = dice_scene.instantiate()
	
	References.segment.add_child(dice)
	dice.move(player.body.global_position + player_offset)
	dice.roll()
	
	return true
