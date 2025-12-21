class_name Observer extends Node3D

@export_group("Body")
@export var head: Node3D
@export var head_turn_rate: float = 1.0
@export var eyes: Array[Node3D] = []
@export var eyes_turn_rate: float = 1.0

@export_group("Target")
@export var target_object: Node3D
var target_position: Vector3 = Vector3.ZERO

func _update(delta: float):
	if not target_object: return
	_update_target()
	_update_head(delta)
	_update_eyes(delta)

func _update_target():
	if not target_object: return
	target_position = target_object.global_position

func _update_head(delta: float):
	if not head: return
	_turn(head, target_position, head_turn_rate * delta)

func _update_eyes(delta: float):
	for eye in eyes:
		if not eye: continue
		_turn(eye, target_position, eyes_turn_rate * delta)

# UTIL TODO Move to a separate script
func _turn(object: Node3D, twords: Vector3, speed: float):
	var current_transform = object.global_transform
	var object_pos = current_transform.origin
	var original_scale = object.scale
	
	var current_basis = current_transform.basis.orthonormalized()
	
	var target_transform = Transform3D()
	target_transform.origin = object_pos
	target_transform = target_transform.looking_at(target_position, Vector3.UP)
	
	var target_basis = target_transform.basis.orthonormalized()
	var new_basis = current_basis.slerp(target_basis, speed)
	
	object.global_transform = Transform3D(new_basis, object_pos)
	object.scale = original_scale

# GENERAL
func _physics_process(delta: float):
	_update(delta)
