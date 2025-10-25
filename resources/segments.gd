class_name WorldSegments extends Resource

# NOTE When exporting make sure resources from path below are included
static var path := "res://scenes/segments/"
static var list := _load_names()

static func _load_names() -> Array:
	var result := []
	var dir = DirAccess.open(path)
	if not dir: return []
	for file in dir.get_files():
		if file.ends_with(".tscn"):
			result.append(file.get_basename())
	return result

static func get_random() -> Node3D:
	var random_name = list[randi() % list.size()]
	return get_by_name(random_name)

static func get_by_name(segment_name: String) -> Node3D:
	var segment_path = path + segment_name + ".tscn"
	if not ResourceLoader.exists(segment_path):
		push_error("Segment not found at: " + segment_path)
		return null
	var scene = load(segment_path)
	return scene.instantiate()
