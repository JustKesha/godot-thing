class_name Items extends Resource

# NOTE When exporting make sure resources from path below are included
static var path := "res://scenes/objects/items/"
static var list := []

static func init_list():
	if len(list) == 0:
		list = _load_names()
	print("Loaded segments: ", list)

static func _static_init():
	init_list()

static func _load_names() -> Array:
	var dir = DirAccess.open(path)
	
	if not dir: 
		push_error("Cannot locate or open '" + path + "'.")
		return []
	
	var result := []
	for file in dir.get_files():
		if file.ends_with(".tscn.remap") or file.ends_with(".tscn"):
			result.append(file.trim_suffix(".remap").get_basename())
	print(result)
	return result

static func get_random() -> Node3D:
	init_list()
	var random_id = list[randi() % list.size()]
	return get_by_id(random_id)

static func get_by_id(item_id: String) -> Node3D:
	init_list()
	var scene = load(path + item_id + ".tscn")
	return scene.instantiate()
