class_name Observer extends Node3D

enum PupilSize { RELAXED = 130, NORMAL = 75, ALERT = 50, HAUNT = 0 }

@export_group("Head")
@export var head: Node3D
@export var head_turn_rate: float = 1.0

@export_group("Eyes")
@export var eyes: Array[Eye] = []
@export var eyes_turn_rate: float = 1.0:
	set(value):
		eyes_turn_rate = value
		for eye in eyes:
			if not eye: continue
			eye.turn_rate = eyes_turn_rate
@export var pupils_size: float = PupilSize.NORMAL:
	set(value):
		pupils_size = value
		for eye in eyes:
			if not eye: continue
			eye.set_pupil_size(pupils_size)

@export_group("Tracking")
@export var target_object: Node3D:
	set(value):
		target_object = value
		for eye in eyes:
			if not eye: continue
			eye.follow(target_object)

func follow(object: Node3D):
	target_object = object

func stop():
	target_object = null

# GENERAL
# NOTE _ready is over-written in ObserverAI
func _physics_process(delta: float):
	if not head or not target_object: return
	Util.turn(head, target_object.global_position, head_turn_rate * delta)
