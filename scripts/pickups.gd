class_name Pickups extends Resource

static var path := "res://scenes/objects/pickups/"
static var comm_prefix := "comm_"
static var comm_chance := -1.0
static var comm: Array[String] = []
static var rare_prefix := "rare_"
static var rare_chance := 30.0
static var rare: Array[String] = []
static var epic_prefix := "epic_"
static var epic_chance := 10.0
static var epic: Array[String] = []

static func _static_init():
	var dir = DirAccess.open(path)
	if not dir: return
	
	for file in dir.get_files():
		if not file.ends_with(".tscn"):
			continue
		var name = file.get_basename()
		
		if name.begins_with(comm_prefix):
			comm.append(name)
		elif name.begins_with(rare_prefix):
			rare.append(name)
		elif name.begins_with(epic_prefix):
			epic.append(name)

static func get_random(roll := -1.0, chance_epic := -1.0, chance_rare := -1.0,
	chance_comm := -1.0, epic_pool: Array[String] = epic,
	rare_pool: Array[String] = rare, comm_pool: Array[String] = comm) -> Node3D:
	if chance_epic < 0: chance_epic = epic_chance
	if chance_rare < 0: chance_rare = rare_chance
	if chance_comm < 0: chance_comm = comm_chance
	
	if chance_comm < 0: chance_comm = 100.0 - chance_epic - chance_rare
	if roll < 0: roll = randf() * 100
	
	if roll < chance_epic:
		return get_epic(epic_pool)
	elif roll < chance_rare + chance_epic:
		return get_rare(rare_pool)
	elif roll < chance_comm + chance_rare + chance_epic:
		return get_comm(comm_pool)
	else:
		return null

static func get_truly_random(pool: Array[String] = comm + rare + epic) -> Node3D:
	return get_by_id(pool.pick_random())

static func get_comm(pool: Array[String] = comm) -> Node3D:
	return Pickups.get_by_id(pool.pick_random() if pool else '')

static func get_rare(pool: Array[String] = rare) -> Node3D:
	return get_by_id(pool.pick_random() if pool else '')

static func get_epic(pool: Array[String] = epic) -> Node3D:
	return get_by_id(pool.pick_random() if pool else '')

static func get_by_id(pickup_id: String) -> Node3D:
	var scene_path = path + pickup_id + ".tscn"
	if not FileAccess.file_exists(scene_path):
		push_error("Pickup not found: ", pickup_id)
		return null
	
	var scene = load(scene_path)
	return scene.instantiate()
