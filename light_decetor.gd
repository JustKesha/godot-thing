extends MeshInstance3D

@export var light_goal: float = 1.0

func _process(delta: float) -> void:
	var dir = 0
	var val = Util.get_light_intensity_at_point(self.global_position)
	
	if val < light_goal: dir = 1
	elif val > light_goal: dir = -1
	
	if dir == 0: return
	self.global_position += Vector3(0,0,.01) * dir
