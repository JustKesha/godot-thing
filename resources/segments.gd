class_name WorldSegments extends Resource

static var path := "res://scenes/segments/"
static var list := _load_names()

static func _load_names() -> Array:
	var result := []
	var dir = DirAccess.open(path)
	if not dir: return []
	
	for file in dir.get_files():
		var resource_name = file.get_basename().trim_suffix(".remap")
		var resource_path = path + resource_name + ".tscn"
		
		if ResourceLoader.exists(resource_path):
			result.append(resource_name)
	return result

static func get_random() -> Node3D:
	if list.is_empty():
		push_error("Segments list is empty")
		return null
	var random_name = list[randi() % list.size()]
	return get_by_name(random_name)

static func get_by_name(segment_name: String) -> Node3D:
	var segment_path = path + segment_name + ".tscn"
	if ResourceLoader.exists(segment_path):
		var scene = load(segment_path)
		return scene.instantiate()
	push_error("Segment not found: " + segment_path)
	return null
