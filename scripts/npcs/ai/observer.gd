class_name ObserverAI extends Observer
## Basic AI for [Observer] that scans the surroundings for new things to lock its gaze onto.

@onready var player := References.player ## The player reference.

@export_group("Scan", "scan_")
## If set to [code]false[/code] will disable scanning.
@export var scan_enabled: bool = true
## [method ObserverAI.scan] will be called on every [signal Timer.timeout].
@export var scan_timer: Timer:
	set(value):
		scan_timer = value
		scan_timer.connect('timeout', scan)
## The [Area3D] in which [ObserverAI] will look for triggers.
## [br][br]NOTE: Some [enum TriggerType]s are global and don't require an [Area3D].
@export var scan_area: Area3D

@export_group("Triggers", "triggers_")
## Determens the objects that [Observer] will be locked onto and the conditions.
enum TriggerType {
	FUEL, ## Tracks the player when fuel is low, changes pupil size based on fuel level.
	DICE, ## Tracks nearby rolling dice.
	INTERACTABLES, ## Tracks Interactables hovered by the player.
	INVENTORY, ## Tracks items held by the player.
	PLAYER ## Tracks the player.
	}
## The order in which the [enum TriggerType]s are checked every [method scan] call.
@export var triggers_priority: Array[TriggerType] = [ 
	TriggerType.FUEL,
	TriggerType.DICE,
	TriggerType.INTERACTABLES,
	TriggerType.INVENTORY,
	TriggerType.PLAYER
	]
## Allows some [enum TriggerType]s to set [member Observer.pupil_size].
@export var triggers_can_change_pupil: bool = true

## Looks for possbile triggers and updates [member Observer.target_object] if one found.
func scan():
	if not scan_enabled: return
	var trigger = get_trigger()
	if not trigger: return
	target_object = trigger

## Returns a [Node3D] that [ObserverAI] is currently most interested in or [code]null[/code].
func get_trigger() -> Node3D:
	for trigger_type in triggers_priority:
		var object = get_trigger_by_type(trigger_type)
		if object: return object
	return null

## Returns a [Node3D] for specific [enum TriggerType] that [ObserverAI] is
## currently most interested in or [code]null[/code].
func get_trigger_by_type(type: TriggerType) -> Node3D:
	match type:
		TriggerType.FUEL:
			var fuel_percentage = player.lantern.fuel_percentage
			if not player.lantern.is_lit:
				if triggers_can_change_pupil: pupil_size = PupilSize.HAUNT
				return player.head # INFO Trigger: Player
			elif fuel_percentage <= 20:
				if triggers_can_change_pupil: pupil_size = PupilSize.ALERT
				return player.head # INFO Trigger: Player
			elif fuel_percentage <= 60:
				if triggers_can_change_pupil: pupil_size = PupilSize.NORMAL
			else:
				if triggers_can_change_pupil: pupil_size = PupilSize.RELAXED
		TriggerType.DICE:
			var bodies = get_area_bodies()
			for trigger in bodies:
				if not trigger: continue
				if trigger is Dice and trigger.is_rolling:
					return trigger.body # INFO Trigger: Rolling Dice
		TriggerType.INTERACTABLES:
			if player.eyes.hovered:
				if triggers_can_change_pupil: pupil_size = PupilSize.RELAXED
				return player.eyes.hovered # INFO Trigger: Hovered Interactable
		TriggerType.INVENTORY:
			if player.inventory.is_open:
				if triggers_can_change_pupil: pupil_size = PupilSize.RELAXED
				return player.inventory # INFO Trigger: Held Item
		TriggerType.PLAYER:
			return player.head # INFO Trigger: Player
	return null

## Returns the result of [method Area3D.get_overlapping_bodies] if
## [member scan_area] is provided else [code][][/code].
func get_area_bodies() -> Array[Node3D]:
	return scan_area.get_overlapping_bodies() if scan_area else []
