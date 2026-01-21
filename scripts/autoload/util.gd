extends Node

## Turns given [param object] to face [param towards] the [Vector3].
## Use [param speed] to define turn rate.
func turn(object: Node3D, towards: Vector3, speed: float = 10.0):
	var current_transform = object.global_transform
	var object_pos = current_transform.origin
	var original_scale = object.scale
	
	var current_basis = current_transform.basis.orthonormalized()
	var target_transform = Transform3D()
	target_transform.origin = object_pos
	target_transform = target_transform.looking_at(towards, Vector3.UP)
	
	var target_basis = target_transform.basis.orthonormalized()
	var new_basis = current_basis.slerp(target_basis, speed)
	
	object.global_transform = Transform3D(new_basis, object_pos)
	object.scale = original_scale

## Get current total light intensity at any given [param point] in space.
## [br]NOTE Only accounts for the [Light3D] objects within the given [param group].
func get_light_intensity_at_point(point: Vector3, group: StringName = "lights") -> float:
	var total = 0.0
	
	for light in get_tree().get_nodes_in_group("lights"):
		if not light.visible: continue
		
		var dist = point.distance_to(light.global_position)
		var attenuation_value = 1.0
		
		if light.has_method("get_omni_attenuation"):
			attenuation_value = light.omni_attenuation
		elif light.has_method("get_spot_attenuation"):
			attenuation_value = light.spot_attenuation
		elif light.has_method("get_attenuation"):
			attenuation_value = light.light_attenuation
		
		var attenuation = 1.0 / (1.0 + attenuation_value * dist * dist)
		total += light.light_energy * attenuation
	
	return total
