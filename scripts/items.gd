class_name Items extends Resource

static var path := "res://scenes/objects/items/"
static var list := _load_names(path)

static func _load_names(path: String) -> Array:
	var result := []
	var dir = DirAccess.open(path)
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tscn"):
				result.append(file.get_basename())
	return result

static func get_random() -> Node3D:
	var random_id = list[randi() % list.size()]
	return get_by_id(random_id)

static func get_by_id(item_id: String) -> Node3D:
	var scene = load(path + item_id + ".tscn")
	return scene.instantiate()
