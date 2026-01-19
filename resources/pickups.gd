class_name Pickups extends Resource
## Stores data about all [Pickup]s and provides access methods.

enum Rarity { ANY = -1, COMMON, RARE, EPIC }
enum Pool { ALL, FOREST, STRUCTURE }
enum Chances { GRIM, SLIM, OKAY, GOOD, BEST }

const CHANCES := {
	Chances.GRIM: {
		Rarity.COMMON: 20.0,
		Rarity.RARE: 10.0,
		Rarity.EPIC: 0.1,
		},
	Chances.SLIM: {
		Rarity.COMMON: 30.0,
		Rarity.RARE: 20.0,
		Rarity.EPIC: 2.5,
		},
	Chances.OKAY: {
		Rarity.COMMON: 50.0,
		Rarity.RARE: 30.0,
		Rarity.EPIC: 5.0,
		},
	Chances.GOOD: {
		Rarity.COMMON: 30.0,
		Rarity.RARE: 40.0,
		Rarity.EPIC: 15.0,
		},
	Chances.BEST: {
		Rarity.COMMON: 20.0,
		Rarity.RARE: 50.0,
		Rarity.EPIC: 30.0,
		},
	}

const PATH := "res://scenes/objects/pickups/"
const EXTN := ".tscn"
const DATA := {
	"candle": {
		"rarity": Rarity.RARE,
		"pools": [Pool.STRUCTURE]
		},
	"pumpkin_small": {
		"rarity": Rarity.COMMON,
		"pools": [Pool.FOREST, Pool.STRUCTURE]
		},
	"pumpkin_large": {
		"rarity": Rarity.RARE,
		"pools": [Pool.FOREST]
		},
	}

## Automatically generated at [method _static_init]. Follows the structure: [br]
## [code]pools = {
##     Pool.TYPE: {
##         Rarity.COMMON: ["pickup_id", ...],
##         Rarity.RARE: [...],
##         Rarity.EPIC: [...],
##     }, ...
## }[/code][br]NOTE: All [Pickup]s are automatically assigned to [member Pool.ALL]
## in addition to their custom pools from [member DATA].
static var pools: Dictionary[Pool, Dictionary] = {}

static func _generate_loot_pools():
	for pool_id in Pool.values():
		pools[pool_id] = {
			Rarity.COMMON: [],
			Rarity.RARE: [],
			Rarity.EPIC: [],
			}
	for pickup_id in DATA.keys():
		var pickup_data = DATA[pickup_id]
		for pool_id in pickup_data["pools"] + [Pool.ALL]:
			var pickup_rarity = pickup_data["rarity"]
			if pickup_rarity == Rarity.ANY:
				pickup_rarity = [Rarity.COMMON, Rarity.RARE, Rarity.EPIC].pick_random()
			if pools.keys().has(pickup_rarity):
				pools[pool_id][pickup_rarity].append(pickup_id)
	Logger.write("LOOT POOLS GENERATED: " + JSON.stringify(pools, "\t"))

static func _static_init():
	_generate_loot_pools()

# ACTIONS

## Get random [Pickup] of certain rarity from given [param pool] or [code]null[/code]
## is nothing found. If [param rarity] < 0 ([member Rarity.ANY]) will use random [member Rarity].
static func get_random(pool: Pool = Pool.ALL, rarity: Rarity = Rarity.ANY) -> Pickup:
	var pickup_ids := get_pickup_ids(pool, rarity)
	if not pickup_ids: return null
	
	return get_by_id(pickup_ids.pick_random())

## Get a [Pickup] instance by an ID [String] or [code]null[/code] if nothing found.
static func get_by_id(pickup_id: String) -> Pickup:
	var pickup_path := PATH + pickup_id + EXTN
	if not ResourceLoader.exists(pickup_path):
		push_error("Pickup by id '" + pickup_id + "' not found.")
		return null
	
	var pickup = load(pickup_path).instantiate() as Pickup
	if not pickup.id:
		pickup.id = pickup_id
	
	return pickup

## Returns a random [Pickup] from given [param pool] if roll [param percent] (default 0.0-100.0) and
## [param chances] (luck) were high enough (see [method get_rarity_by_roll]) otherwise returns [code]null[/code].
static func get_by_roll(pool: Pool = Pool.ALL,
	chances: Chances = Chances.OKAY, percent: float = -1) -> Pickup:
	var rarity = get_rarity_by_roll(chances, percent)
	if rarity < 0: return null
	
	return get_random(pool, rarity)

# HELPERS

## Get list of [Pickup] ID [String]s for specific [enum Pool] and [enum Rarity].
## If [param rarity] < 0 ([member Rarity.ANY]) will use random [enum Rarity].
static func get_pickup_ids(pool: Pool = Pool.ALL,
	rarity: Rarity = Rarity.ANY) -> Array:
	if rarity < 0: rarity = [Rarity.COMMON, Rarity.RARE, Rarity.EPIC].pick_random()
	return pools[pool][rarity] as Array

## Get percent chance for a [Pickup] of certain [enum Rarity] appearing with given luck
## ([param chances]). If [param rarity] < 0 ([member Rarity.ANY]) will use random [enum Rarity].
static func get_rarity_chance(rarity: Rarity = Rarity.ANY,
	chances: Chances = Chances.OKAY) -> float:
	if rarity < 0: rarity = [Rarity.COMMON, Rarity.RARE, Rarity.EPIC].pick_random()
	return CHANCES[chances][rarity] as float

## Get [Pickup] [enum Rarity] from a roll [param percent] and luck ([param chances]).
## The higher the [param chances] the less roll [param percent] you need to get a higher
## [enum Rarity]. By default [param percent] is a random [float] from 0 to 100.
## [br]NOTE: Will return [member Rarity.ANY] (-1) if no other [enum Rarity] could be achieved.
static func get_rarity_by_roll(chances: Chances = Chances.OKAY,
	percent: float = -1) -> Rarity:
	if percent < 0: percent = randf() * 100
	
	var count := 0
	for rarity in [Rarity.COMMON, Rarity.RARE, Rarity.EPIC]:
		count += get_rarity_chance(rarity, chances)
		if percent < count: return rarity
	
	return Rarity.ANY
