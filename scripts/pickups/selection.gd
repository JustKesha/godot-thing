class_name PickupSelection extends Node

@onready var player := References.player
@onready var dialogue_window := References.player.dialogue_window

@export_group("Spawners")
@export var spawners: Array[PickupSpawner] = []

@export_group("Responses", "responses_")
@export var responses_appear: Array[String] = []
@export var responses_disappear: Array[String] = []

func init():
	for spawner in spawners:
		if spawner:
			spawner.disappearing.connect(_on_any_stand_disappearing)
			spawner.disappeared.connect(_on_any_stand_disappeared)

func appear():
	for spawner in spawners:
		if spawner: spawner.appear()
	player.lock(get_path())
	if responses_appear:
		dialogue_window.display(responses_appear.pick_random())

func disappear():
	for spawner in spawners:
		if spawner: spawner.disappear()
	if responses_disappear:
		dialogue_window.display(responses_disappear.pick_random())

func remove():
	disappear()
	player.unlock(get_path())

# GENERAL

func _ready():
	init()

func _on_trigger_triggered():
	appear()

func _on_any_stand_disappearing():
	disappear()

func _on_any_stand_disappeared():
	remove()
