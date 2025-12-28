class_name PickupSelection extends Node

@onready var player := References.player
@onready var dialogue_window := References.player.dialogue_window

@export var stands: Array[PickupStand] = []
@export var responses_appear: Array[String] = []
@export var responses_disappear: Array[String] = []

func appear():
	for stand in stands:
		stand.appear()
	
	player.lock(get_path())
	if responses_appear:
		dialogue_window.display(responses_appear.pick_random())

func disappear():
	for stand in stands:
		if stand: stand.disappear()
	
	player.unlock(get_path())
	if responses_disappear:
		dialogue_window.display(responses_disappear.pick_random())

# GENERAL

func _ready():
	for stand in stands:
		stand.disappearing.connect(_on_any_stand_disappearing)

# TODO FIXME Instead use PlayerMovementController's distance traveled to determen
# when area reached NOTE When done, remove player's hitbox & collision layer
func _on_trigger_body_entered(_body: Node3D):
	appear()

func _on_any_stand_disappearing():
	disappear()
