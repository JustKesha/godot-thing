class_name WorldSegments extends Resource

static var list := [
	preload("res://scenes/segments/fence_a.tscn"),
	preload("res://scenes/segments/fence_b.tscn"),
	preload("res://scenes/segments/fence_c.tscn"),
	preload("res://scenes/segments/gates_a.tscn"),
	preload("res://scenes/segments/gates_b.tscn"),
	preload("res://scenes/segments/graves_a.tscn"),
	
	preload("res://scenes/segments/light_post_a.tscn"),
	preload("res://scenes/segments/light_post_a.tscn"),
	preload("res://scenes/segments/light_post_a.tscn"),
	
	preload("res://scenes/segments/light_post_b.tscn"),
	preload("res://scenes/segments/light_post_c.tscn"),
	
	preload("res://scenes/segments/trees_a.tscn"),
	preload("res://scenes/segments/trees_a.tscn"),
	preload("res://scenes/segments/trees_a.tscn")
]

static func get_random() -> Node3D:
	return list[randi() % list.size()].instantiate()

static func get_by_name(segment_name: String) -> Node3D:
	for scene in list:
		if scene.resource_path.get_file().get_basename() == segment_name:
			return scene.instantiate()
	return null
