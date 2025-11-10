class_name InteractableDice extends Interactable

@export var body: RigidBody3D

@export_group("Roll Animation")
@export var roll_dir: Vector3 = Vector3.UP
@export var roll_speed: float = 5.0
@export var roll_rotation_speed: float = 2.5

# TEMP
@onready var origin_pos: Vector3 = body.position

func _on_interact(_player: PlayerAPI):
	body.position = origin_pos
	body.apply_central_impulse(roll_dir * roll_speed)
	body.apply_torque_impulse(
		Vector3(randf(), randf(), randf()) * roll_rotation_speed)
