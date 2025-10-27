class_name Items extends Resource

# NOTE When exporting make sure resources from path below are included
static var path := "res://scenes/objects/items/"
static var list

static func _static_init():
	list = _load_names()

static func _load_names() -> Array:
	var dir = DirAccess.open(path)
	
	if not dir: 
		push_error("Cannot locate or open '" + path + "'.")
		return []
	
	var result := []
	for file in dir.get_files():
		if file.ends_with(".tscn.remap") or file.ends_with(".tscn"):
			result.append(file.trim_suffix(".remap").get_basename())
	return result

static func get_random() -> Node3D:
	var random_id = list[randi() % list.size()]
	return get_by_id(random_id)

static func get_by_id(item_id: String) -> Node3D:
	var scene = load(path + item_id + ".tscn")
	return scene.instantiate()
