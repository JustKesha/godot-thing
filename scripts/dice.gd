class_name Dice extends RigidBody3D

@export var body: RigidBody3D

@export_group("Roll")
@export var roll_dir: Vector3 = Vector3.UP
@export var roll_speed: float = 3.5
@export var roll_rotation_speed: float = 2.5
@export var faces = [
	[Vector3.UP, 1],
	[Vector3.DOWN, 6], 
	[Vector3.LEFT, 3],
	[Vector3.RIGHT, 4],
	[Vector3.FORWARD, 2],
	[Vector3.BACK, 5]
]
var is_rolling: bool = false

func roll():
	if is_rolling: return
	# NOTE Not using apply impulse for velocity bc slow
	# (Will stop the roll same frame in _physics_process, linear_velocity ~= 0)
	body.linear_velocity = roll_dir * roll_speed
	body.apply_torque_impulse(
		Vector3(randf(), randf(), randf()) * roll_rotation_speed)
	is_rolling = true

func stop():
	print('Dice stopped')
	print('Rolled ', get_score())
	is_rolling = false

func get_score() -> int:
	var best_score = 0
	var best_dot = -1.0

	for face in faces:
		var normal = body.global_transform.basis * face[0]
		var dot = normal.dot(Vector3.UP)
		if dot > best_dot:
			best_dot = dot
			best_score = face[1]

	return best_score

func _physics_process(delta: float):
	if not is_rolling: return
	if( body.linear_velocity.length() < 0.1
		and body.angular_velocity.length() < 0.1 ):
		stop()
