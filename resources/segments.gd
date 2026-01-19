class_name WorldSegments extends Resource

enum Rarity { ANY = -1, COMMON = 0, RARE = 1, EPIC = 2 }
enum Chances { GRIM, SLIM, OKAY, GOOD, NICE }
const CHANCES := [
	[30.0, 10.0,  2.5],
	[40.0, 15.0,  5.0],
	[60.0, 20.0, 10.0],
	[50.0, 30.0, 15.0],
	[40.0, 40.0, 20.0],
	]

const path := "res://scenes/segments/"
const extn := ".tscn"
const data := {
	"fence_a": { "rarity": Rarity.COMMON },
	"fence_b": { "rarity": Rarity.COMMON },
	"fence_c": { "rarity": Rarity.RARE },
	
	"gates_a": { "rarity": Rarity.RARE },
	"gates_b": { "rarity": Rarity.EPIC },
	
	"trees_a": { "rarity": Rarity.COMMON },
	"graves_a": { "rarity": Rarity.EPIC },
	
	"light_post_a": { "rarity": Rarity.EPIC },
	"light_post_b": { "rarity": Rarity.COMMON },
	"light_post_c": { "rarity": Rarity.RARE },
	
	"pickup_selection": { "rarity": Rarity.RARE },
}

static var scenes: Dictionary[String, PackedScene] = {}
static var ids: Array[Array]

static func roll(chances: Chances = Chances.GOOD,
	percent: float = -1) -> WorldSegment:
	if percent < 0: percent = randf_range(0.0, 100.0)
	
	var rarity := 0
	var chance := 0.0
	for rarity_chance in CHANCES[chances]:
		chance += rarity_chance
		if percent <= chance: return get_random(rarity)
		rarity += 1
	return null

static func get_random(rarity: Rarity = Rarity.ANY) -> WorldSegment:
	match rarity:
		Rarity.COMMON, Rarity.RARE, Rarity.EPIC:
			return get_segment(ids[rarity].pick_random())
		Rarity.ANY:
			return scenes.values().pick_random().instantiate()
	push_error("Segment rarity '" + str(rarity) + "' not found.")
	return null

static func get_segment(id: String) -> WorldSegment:
	if id in scenes:
		return scenes[id].instantiate()
	push_error("Segment by id '" + id + "' not found.")
	return null

static func _static_init():
	while len(ids) <= len(Rarity.values()): ids.append([])
	for id in data.keys():
		var scene: PackedScene = load(path + id + extn)
		scenes[id] = scene
		
		var rarity = data[id]["rarity"] as int
		if rarity < 0: rarity = Rarity.values().pick_random()
		ids[rarity].append(id)
