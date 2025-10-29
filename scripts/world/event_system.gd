class_name EventsSystem extends Node

@export var player_api: PlayerAPI
var is_event_ungoing := false

@export_group("Random Events")
@export var random_event_timer: Timer
@export var random_events_min_interval := 10.0
@export var random_events_max_interval := 30.0

enum Events {
	RANDOM = 0,
	MOON = 1,
	}
var RandomEventsPool = [
	Events.MOON,
]

func play_event(event_id: Events = Events.RANDOM) -> bool:
	var event_scene_path: String
	
	match event_id:
		Events.MOON:
			player_api.dialogue_window.display([
				"You feel as if the moon is watching you...",
				"The moon feels off...",
				"You feel like you're being watched...",
			].pick_random())
			player_api.camera.look(player_api.moon, 2.75)
			player_api.lantern.fuel -= 25
		Events.RANDOM:
			return play_event(RandomEventsPool.pick_random())
		_:
			push_error("No event with id '",event_id,"' found.")
			return false
	
	is_event_ungoing = true
	return true

func start__random_event_timer():
	random_event_timer.start(randf_range(random_events_min_interval,
		random_events_max_interval))

func _on_random_event_timeout():
	play_event(Events.RANDOM)
	start__random_event_timer()

func _ready():
	start__random_event_timer()
