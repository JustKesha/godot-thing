extends Item

@export var dice_scene: PackedScene
@export var player_offset: Vector3 = Vector3(0,3,-1.75)

func _on_use() -> bool:
	var dice: Dice = dice_scene.instantiate()
	var segment: WorldSegment = References.world.generator.current_segment
	var player: Node3D = References.player.body
	segment.add_child(dice)
	dice.move(player.global_position + player_offset)
	dice.init()
	dice.roll()
	# FIXME ^
	return true
