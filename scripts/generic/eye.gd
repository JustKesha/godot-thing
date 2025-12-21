class_name Eye extends Node

enum Pupil { RELAXED = 150, NORMAL = 100, ALERT = 50 }
var pupil_size_divider = 100.0

@export_group("Eyeball")
@export var eyeball: Node3D
@export var turn_rate: float = 1.0

@export_group("Pupil")
@export var pupil: Node3D
@export var pupil_dilation_speed: float = 1.0
@export var pupil_constriction_speed: float = 5.0
var pupil_size: float
var pupil_target_size: float:
	set(value):
		pupil_target_size = value
		pupil_transition_speed = (
			pupil_dilation_speed if pupil_target_size > pupil_size
			else pupil_constriction_speed )
var pupil_transition_speed: float

@export_group("Tracking")
@export var target_object: Node3D
@export var target_position: Vector3 = Vector3.FORWARD

func follow(object: Node3D):
	target_object = object

func turn(twords: Vector3):
	stop()
	target_position = twords

func stop():
	target_object = null

func set_pupil(type: Pupil = Pupil.NORMAL):
	pupil_target_size = float(type)

func set_pupil_size(value: float):
	pupil_target_size = value

func _update_eyeball(delta: float):
	if not eyeball: return
	
	if target_object: target_position = target_object.global_position
	Util.turn(eyeball, target_position, turn_rate * delta)

func _update_pupils(delta: float):
	if not pupil: return
	
	pupil_size = lerp(pupil_size, pupil_target_size, pupil_transition_speed * delta)
	pupil.scale = Vector3.ONE * pupil_size/pupil_size_divider

# GENERAL

func _ready():
	set_pupil()

func _process(delta: float):
	_update_eyeball(delta)
	_update_pupils(delta)
