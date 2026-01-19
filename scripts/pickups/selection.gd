class_name PickupSelection extends Node

signal appearing()
signal disappearing()
signal removed()

@onready var player := References.player
@onready var dialogue_window := References.player.dialogue_window

@export_group("Spawners")
@export var spawners: Array[PickupSpawner] = []

@export_group("Responses", "responses_")
@export var responses_appear: Array[String] = []
@export var responses_disappear: Array[String] = []

func appear():
	player.lock(get_path())
	for spawner in spawners: if spawner: spawner.appear()
	if responses_appear: dialogue_window.display(responses_appear.pick_random())
	appearing.emit()

func disappear():
	for spawner in spawners: if spawner: spawner.disappear()
	if responses_disappear: dialogue_window.display(responses_disappear.pick_random())
	disappearing.emit()

func _remove():
	player.unlock(get_path())
	queue_free()
	removed.emit()

# GENERAL

func _ready():
	for spawner in spawners:
		if spawner:
			spawner.disappearing.connect(_on_any_stand_disappearing)
			spawner.disappeared.connect(_on_any_stand_disappeared)

func _on_trigger_triggered():
	appear()

func _on_any_stand_disappearing():
	disappear()

func _on_any_stand_disappeared():
	_remove()
