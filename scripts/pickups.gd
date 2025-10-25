class_name Pickups extends Resource

static var comm_chance := -1.0
static var comm: Array[Resource] = [
	preload("res://scenes/objects/pickups/candle.tscn"),
]
static var rare_prefix := "rare_"
static var rare_chance := 30.0
static var rare: Array[Resource] = [
	preload("res://scenes/objects/pickups/pumpkin_small.tscn"),
]
static var epic_prefix := "epic_"
static var epic_chance := 10.0
static var epic: Array[Resource] = [
	preload("res://scenes/objects/pickups/pumpkin.tscn"),
]
static var all: Array[Resource] = comm + rare + epic

enum PickupPool {
	ALL = 0,
	FOREST = 1,
	BENCH = 2
}

enum Chances {
	NONE = 0, GRIM = 1, SLIM = 2, OKAY = 3, GOOD = 4, EASY = 5
}

static func _get_random(roll := -1.0, chance_epic := -1.0, chance_rare := -1.0,
	chance_comm := -1.0, epic_pool: Array[Resource] = epic,
	rare_pool: Array[Resource] = rare, comm_pool: Array[Resource] = comm) -> Node3D:
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
			rare_pool = [preload("res://scenes/objects/pickups/pumpkin.tscn")]
			epic_pool = [preload("res://scenes/objects/pickups/candle.tscn")]
		PickupPool.BENCH:
			comm_pool = [preload("res://scenes/objects/pickups/candle.tscn")]
			rare_pool = [preload("res://scenes/objects/pickups/pumpkin_small.tscn")]
			epic_pool = [preload("res://scenes/objects/pickups/pumpkin.tscn")]
	
	var chance_comm := -1
	var chance_rare := -1
	var chance_epic := -1
	
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

static func get_truly_random(pool: Array[Resource] = all) -> Node3D:
	return get_by_id(pool.pick_random())

static func get_comm(pool: Array[Resource] = comm) -> Node3D:
	if not len(pool): return null
	return pool.pick_random().instantiate()

static func get_rare(pool: Array[Resource] = rare) -> Node3D:
	if not len(pool): return null
	return pool.pick_random().instantiate()

static func get_epic(pool: Array[Resource] = epic) -> Node3D:
	if not len(pool): return null
	return pool.pick_random().instantiate()

static func get_by_id(pickup_id: String) -> Node3D:
	for scene in all:
		if scene.resource_path.get_file().get_basename() == pickup_id:
			return 
			return scene.instantiate()
	push_error("Pickup not found: ", pickup_id)
	return null
