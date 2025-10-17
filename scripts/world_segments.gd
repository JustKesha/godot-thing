class_name WorldSegments extends Resource

static var path := "res://scenes/segments/"
static var list := _load_names()

static func _load_names() -> Array:
	var result := []
	var dir = DirAccess.open(path)
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tscn"):
				result.append(file.get_basename())
	return result

static func get_random() -> Node3D:
	var random_name = list[randi() % list.size()]
	return get_by_name(random_name)

static func get_by_name(segment_name: String) -> Node3D:
	var scene = load(path + segment_name + ".tscn")
	return scene.instantiate()
