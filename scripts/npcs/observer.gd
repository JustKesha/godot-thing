class_name Observer extends Node3D

enum PupilSize { RELAXED = 130, NORMAL = 75, ALERT = 50, HAUNT = 0 }

@export_group("Head")
@export var head: Node3D
@export var head_turn_rate: float = 1.0

@export_group("Eyes")
@export var eyes: Array[Eye] = []
@export var eyes_turn_rate: float = 1.0
@export var pupils_size: float = PupilSize.NORMAL

@export_group("Tracking")
@export var target_object: Node3D
@export var turn_rate: float = 1.0

func follow(object: Node3D):
	target_object = object

func stop():
	target_object = null

func _update_head(delta: float):
	if not head: return
	Util.turn(head, target_object.global_position, head_turn_rate * delta)

func _update_eyes():
	for eye in eyes:
		if not eye: continue
		eye.turn_rate = eyes_turn_rate
		eye.set_pupil_size(pupils_size)
		eye.turn(target_object.global_position)

# GENERAL
func _ready():
	eyes_turn_rate = eyes_turn_rate

func _physics_process(delta: float):
	if not target_object: return
	_update_head(delta)
	_update_eyes()
