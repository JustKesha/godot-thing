class_name Dice extends Node

@export var body: RigidBody3D
@export var interactable: Interactable

@export_group("Roll")
@export var roll_limit: int = 1
@export var lock_camera_on_roll: bool = false
@export var roll_direction: Vector3 = Vector3.UP
@export var roll_speed: float = -1.0:
	get(): return (
		roll_speed if roll_speed >= 0
		else randf_range(roll_speed_min, roll_speed_max)
	)
@export var roll_speed_min: float = 2.5
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
@export var roll_angular_speed_min: float = 7.5
@export var roll_angular_speed_max: float = 10.0

@export_group("Auto Destroy")
@export var destroy_timer: Timer
@export var destroy_on_roll_limit: bool = true
@export var destroy_delay: float = 2.0
var is_queued_for_destroy: bool = false

@export_group("Projector")
@export var spawn_projector: bool = false
@export var projector_scene: PackedScene
@export var projector_offset: Vector3 = Vector3.UP * 2.5
var projector: Projector:
	set(value):
		if projector != null: projector.queue_free()
		projector = value
		body.get_parent().add_child(projector)

@export_group("Responses")
@export var roll_react: bool = false
@export var roll_reactions: Array[Array] = [
	["1...", "1?!"], ["2.."], ["3."], ["4."], ["5!"], ["6!"]
]

@export_group("Faces")
@export var faces = [
	[Vector3.UP, 1],
	[Vector3.DOWN, 6], 
	[Vector3.LEFT, 3],
	[Vector3.RIGHT, 4],
	[Vector3.FORWARD, 2],
	[Vector3.BACK, 5]
]

var is_ready_to_roll: bool = true:
	get(): return ( not is_rolling and roll_count < roll_limit
		and not is_queued_for_destroy )
var is_rolling: bool = false:
	set(value):
		is_rolling = value
		interactable.is_enabled = not is_rolling
		if is_rolling:
			if lock_camera_on_roll:
				References.player.camera.lock(body,-1,false,true)
		else:
			if lock_camera_on_roll:
				References.player.camera.face(body)
var roll_count: int = 0
var score: int = 5:
	set(value):
		score = value
		score_total += score
var score_total: int = 0

func _on_roll_started(): pass
func _on_roll_finished(): pass
func _on_roll_limit(): pass
func _on_remove(): pass

func init():
	if spawn_projector:
		if not projector: projector = projector_scene.instantiate()
		projector.spectating = body
		projector.global_position = body.global_position + projector_offset

func roll(speed: float = roll_speed, angular_speed: float = roll_angular_speed):
	if not is_ready_to_roll: return
	# NOTE Not using apply impulse bc slow
	# ^ Will stop the roll same frame in _physics_process bc linear_velocity ~= 0
	body.linear_velocity = roll_direction * speed
	body.angular_velocity = roll_angular_direction * angular_speed
	is_rolling = true
	roll_count += 1
	_on_roll_started()

func stop():
	score = get_score()
	is_rolling = false
	_on_roll_finished()
	if roll_count >= roll_limit:
		_on_roll_limit()
		if destroy_on_roll_limit: destroy()
	if roll_react:
		if( score >= 0
			and score-1 < len(roll_reactions)
			and len(roll_reactions[score-1]) > 0 ):
			References.player.dialogue_window.display(
				roll_reactions[score-1].pick_random())

func move(to: Vector3):
	body.global_position = to

func destroy(delay: float = destroy_delay):
	destroy_timer.start(delay)
	is_queued_for_destroy = true

func remove():
	_on_remove()
	queue_free()
	interactable.remove()

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

func _ready():
	init()

func _physics_process(delta: float):
	if not is_rolling: return
	if( body.linear_velocity.length() < 0.1
		and body.angular_velocity.length() < 0.1 ):
		stop()

func _on_destroy_timer_timeout():
	remove()
