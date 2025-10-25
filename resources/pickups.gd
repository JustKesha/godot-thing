class_name Pickups extends Resource

# NOTE When exporting make sure resources from path below are included
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

enum PickupPool {
	ALL = 0,
	FOREST = 1,
	BENCH = 2
}

enum Chances {
	NONE = 0, GRIM = 1, SLIM = 2, OKAY = 3, GOOD = 4, EASY = 5
}

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

static func _get_random(roll := -1.0, chance_epic := -1.0, chance_rare := -1.0,
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

static func get_random(pool: PickupPool = PickupPool.ALL,
	chances: Chances = Chances.OKAY, roll := -1.0):

	var comm_pool := comm
	var rare_pool := rare
	var epic_pool := epic

	match pool:
		PickupPool.ALL:
			pass
		PickupPool.FOREST:
			comm_pool = []
			rare_pool = ['rare_pumpkin']
			epic_pool = ['epic_pumpkin']
		PickupPool.BENCH:
			comm_pool = ['comm_candle']
			rare_pool = ['rare_pumpkin']
			epic_pool = ['epic_pumpkin']
	
	var chance_comm := -1.0
	var chance_rare := -1.0
	var chance_epic := -1.0

	match chances:
		Chances.NONE:
			chance_comm = 0.0
			chance_rare = 0.0
			chance_epic = 0.0
		Chances.GRIM:
			chance_comm = 12.0
			chance_rare = 4.5
			chance_epic = 1.0
		Chances.SLIM:
			chance_comm = 25.0
			chance_rare = 7.5
			chance_epic = 2.5
		Chances.OKAY:
			chance_comm = 40.0
			chance_rare = 15.0
			chance_epic = 5.0
		Chances.GOOD:
			chance_comm = 50.0
			chance_rare = 30.0
			chance_epic = 10.0
		Chances.EASY:
			chance_comm = -1.0
			chance_rare = 45.0
			chance_epic = 20.0

	return _get_random(roll, chance_epic, chance_rare, chance_comm, epic_pool,
		rare_pool, comm_pool)

static func get_truly_random(pool: Array[String] = comm + rare + epic) -> Node3D:
	return get_by_id(pool.pick_random())

static func get_comm(pool: Array[String] = comm) -> Node3D:
	return Pickups.get_by_id(pool.pick_random() if pool else '')

static func get_rare(pool: Array[String] = rare) -> Node3D:
	return get_by_id(pool.pick_random() if pool else '')

static func get_epic(pool: Array[String] = epic) -> Node3D:
	return get_by_id(pool.pick_random() if pool else '')

static func get_by_id(pickup_id: String) -> Node3D:
	var pickup_path = path + pickup_id + ".tscn"
	if not ResourceLoader.exists(pickup_path):
		push_error("Segment not found at: " + pickup_path)
		return null
	var pickup_scene = load(pickup_path)
	return pickup_scene.instantiate()
