class_name ObserverAI extends Observer

@onready var player: PlayerAPI = References.player
@export var interest_area: Area3D
@export var update_timer: Timer

func scan():
	var trigger = get_trigger()
	if not trigger: return
	target_object = trigger

func get_trigger() -> Node3D:
	var bodies = interest_area.get_overlapping_bodies() if interest_area else []
	var fuel_percentage = player.lantern.fuel_percentage
	
	# Player
	if not player.lantern.is_lit:
		pupils_size = float(PupilSize.HAUNT)
		return player.head
		
	# Player
	elif fuel_percentage <= 20:
		pupils_size = float(PupilSize.ALERT)
		return player.head
		
	elif fuel_percentage <= 60:
		pupils_size = float(PupilSize.NORMAL)
	else:
		pupils_size = float(PupilSize.RELAXED)
	
	# Rolling Dice
	for trigger in bodies:
		if not trigger: continue
		if trigger is Dice and trigger.is_rolling:
			return trigger.body
	
	# Hovered Interactables
	if player.eyes.hovered:
		return player.eyes.hovered
	
	# Held Items
	if player.inventory.is_open:
		return player.inventory
	
	# Player
	return player.head

# GENERAL
func _ready():
	if update_timer: update_timer.connect('timeout', _on_update_timer_timeout)

func _on_update_timer_timeout():
	scan()
