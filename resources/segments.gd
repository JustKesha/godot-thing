class_name WorldSegments extends Resource

enum Rarity { ANY = -1, COMMON = 0, RARE = 1, EPIC = 2 }

const path := "res://scenes/segments/"
const extn := ".tscn"
const data := {
	"fence_a": { "rarity": Rarity.COMMON },
	"fence_b": { "rarity": Rarity.RARE },
	"fence_c": { "rarity": Rarity.EPIC },
}

static var scenes: Dictionary[String, PackedScene] = {}
static var ids: Array[Array]

static func _static_init():
	for id in data.keys():
		var scene: PackedScene = load(path + id + extn)
		scenes[id] = scene
		
		var rarity = data[id]["rarity"] as int
		if rarity < 0: rarity = Rarity.values()[randi() % Rarity.size()]
		while len(ids) <= rarity: ids.append([])
		ids[rarity].append(id)
	print(ids)

static func get_random(rarity: Rarity = Rarity.ANY) -> WorldSegment:
	match rarity:
		Rarity.COMMON, Rarity.RARE, Rarity.EPIC:
			return get_segment(ids[rarity].pick_random())
		Rarity.ANY:
			return scenes.values().pick_random().instantiate()
	push_error("Segment rarity #" + str(rarity) + " not found.")
	return null

static func get_segment(id: String) -> WorldSegment:
	if id in scenes:
		return scenes[id].instantiate()
	push_error("Segment '" + id + "' not found.")
	return null
