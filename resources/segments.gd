class_name WorldSegments extends Resource

enum Rarity { ANY = -1, COMMON = 0, EPIC = 1, RARE = 2 }

const path := "res://scenes/segments/"
const extn := ".tscn"
const data := {
	"fence_a": { "rarity": Rarity.ANY },
	"fence_b": { "rarity": Rarity.RARE },
	"fence_c": { "rarity": Rarity.RARE },
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

static func get_random(rarity: Rarity = -1) -> WorldSegment:
	return scenes.values().pick_random().instantiate()

static func get_segment(id: String) -> WorldSegment:
	if not id in scenes:
		push_error("Segment '" + id + "' not found.")
		return null
	return scenes[id].instantiate()
