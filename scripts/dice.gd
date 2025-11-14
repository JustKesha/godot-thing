class_name Dice extends RigidBody3D

@export var body: RigidBody3D
var is_rolling: bool = false

@export_group("Roll")
@export var roll_direction: Vector3 = Vector3.UP
@export var roll_speed: float = -1.0:
	get(): return (
		roll_speed if roll_speed >= 0
		else randf_range(roll_speed_min, roll_speed_max)
	)
@export var roll_speed_min: float = 3.5
@export var roll_speed_max: float = 5.0
@export var roll_angular_direction: Vector3 = Vector3(2.6, 0.8, 2.3):
	get(): return (
		roll_angular_direction if roll_angular_direction != Vector3(2.6,0.8,2.3)
		else Vector3(
			[-1,1].pick_random(),
			randf_range(-1, 1),
			[-1,1].pick_random()
		)
	)
@export var roll_angular_speed: float = -1.0:
	get(): return (
		roll_angular_speed if roll_angular_speed >= 0
		else randf_range(roll_angular_speed_min, roll_angular_speed_max)
	)
@export var roll_angular_speed_min: float = 9.5
@export var roll_angular_speed_max: float = 9.5

@export_group("Values")
@export var faces = [
	[Vector3.UP, 1],
	[Vector3.DOWN, 6], 
	[Vector3.LEFT, 3],
	[Vector3.RIGHT, 4],
	[Vector3.FORWARD, 2],
	[Vector3.BACK, 5]
]

func roll(speed: float = roll_speed, angular_speed: float = roll_angular_speed):
	if is_rolling: return
	# NOTE Not using apply impulse bc slow
	# ^ Will stop the roll same frame in _physics_process bc linear_velocity ~= 0
	body.linear_velocity = roll_direction * speed
	body.angular_velocity = roll_angular_direction * angular_speed
	is_rolling = true

func stop():
	print('Dice stopped')
	var score = get_score()
	print('Rolled ', score)
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
