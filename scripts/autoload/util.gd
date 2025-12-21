extends Node

func turn(object: Node3D, twords: Vector3, speed: float):
	var current_transform = object.global_transform
	var object_pos = current_transform.origin
	var original_scale = object.scale
	
	var current_basis = current_transform.basis.orthonormalized()
	
	var target_transform = Transform3D()
	target_transform.origin = object_pos
	target_transform = target_transform.looking_at(twords, Vector3.UP)
	
	var target_basis = target_transform.basis.orthonormalized()
	var new_basis = current_basis.slerp(target_basis, speed)
	
	object.global_transform = Transform3D(new_basis, object_pos)
	object.scale = original_scale
