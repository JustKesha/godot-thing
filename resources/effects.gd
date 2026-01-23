class_name Effects extends Resource

enum Type { NEGATIVE = -1, NEUTRAL = 0, POSITIVE = 1}

const PATH := "res://scenes/objects/effects/"
const EXTN := ".tscn"
const DATA := {
	"regeneration": {
		"name": "Regeneration",
		"desc": "Restoring 1 fuel a second per stack.",
		"type": Type.POSITIVE
		},
	"satiety": {
		"name": "Satiety",
		"desc": "You're full. Restoring 3 fuel each second.",
		"type": Type.POSITIVE
		},
	}

## Automatically generated at [method _static_init] using [method _generate_type_pools].
static var types: Dictionary[Type, Array] = {
	Type.NEUTRAL: [],
	Type.POSITIVE: [],
	Type.NEGATIVE: [],
	}

static func _generate_type_pools():
	for effect_id in DATA.keys():
		var effect_data = DATA[effect_id]
		if types.has(effect_data["type"]):
			types[effect_data["type"]].append(effect_id)
	Logger.write("EFFECTS LOADED: " + JSON.stringify(types, "\t"))

static func _static_init():
	_generate_type_pools()

# ACTIONS

static func get_by_id(effect_id: StringName) -> Effect:
	var effect_path := PATH + effect_id + EXTN
	if not ResourceLoader.exists(effect_path):
		push_error("Effect by id '" + effect_id + "' not found.")
		return null
	
	var effect = load(effect_path).instantiate() as Effect
	
	effect.effect_id = effect_id
	effect.effect_name = DATA[effect_id]["name"]
	effect.effect_desc = DATA[effect_id]["desc"]
	effect.effect_type = DATA[effect_id]["type"]
	
	return effect

static func get_random(effect_type: Type = -2) -> Effect:
	if not Type.values().has(effect_type):
		effect_type = Type.values().pick_random()
	return get_by_id(types[effect_type].pick_random())

# HELPERS

static func get_effect_name(effect_id: StringName) -> String:
	if not DATA.has(effect_id): return ""
	return DATA[effect_id]["name"]

static func get_effect_desc(effect_id: StringName) -> String:
	if not DATA.has(effect_id): return ""
	return DATA[effect_id]["desc"]

static func get_effect_type(effect_id: StringName) -> Type:
	if not DATA.has(effect_id): return Type.NEUTRAL
	return DATA[effect_id]["type"]
