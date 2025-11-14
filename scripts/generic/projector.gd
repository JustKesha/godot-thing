class_name Projector extends SpotLight3D

@export var spectating: Node3D

func remove(): queue_free()

func _process(delta):
	if not spectating: return remove()
	look_at(spectating.global_position)
