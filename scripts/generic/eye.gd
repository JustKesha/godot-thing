class_name Eye extends Node

@export var is_sleeping: bool = false

@export_group("Eyeball")
@export var eyeball: Node3D
@export var turn_rate: float = 1.0

@export_group("Pupil")
const pupil_size_multiplier = 0.01
@export var pupil: Node3D
@export var pupil_dilation_speed: float = 1.0
@export var pupil_constriction_speed: float = 5.0
@onready var pupil_size: float = pupil.scale.y if pupil else 1:
	set(value):
		pupil_size = value
		if pupil: pupil.scale = Vector3.ONE * pupil_size * pupil_size_multiplier
		is_pupil_moving = true
var pupil_target_size: float = pupil_size:
	set(value):
		if is_equal_approx(value, pupil_target_size): return
		pupil_target_size = value
		pupil_transition_speed = (
			pupil_dilation_speed if pupil_target_size > pupil_size
			else pupil_constriction_speed )
		is_pupil_moving = true
var pupil_transition_speed: float = pupil_dilation_speed
var is_pupil_moving: bool = false

@export_group("Tracking")
@export var target_object: Node3D:
	set(value):
		target_object = value
		is_sleeping = false
@export var target_position: Vector3 = Vector3.FORWARD:
	set(value):
		target_position = value
		is_sleeping = false

func follow(object: Node3D):
	target_object = object

func turn(twords: Vector3):
	target_object = null
	target_position = twords

func stop():
	target_object = null
	is_sleeping = true

func set_pupil_size(size: float):
	pupil_target_size = size

func _update_eyeball(delta: float):
	if not eyeball: return
	Util.turn(eyeball, target_position, turn_rate * delta)

func _update_pupil(delta: float):
	if not is_pupil_moving: return
	
	pupil_size = lerp(pupil_size, pupil_target_size, pupil_transition_speed * delta)
	if is_equal_approx(pupil_size, pupil_target_size): is_pupil_moving = false

func _process(delta: float):
	if is_sleeping: return
	if target_object: target_position = target_object.global_position
	_update_eyeball(delta)
	_update_pupil(delta)
