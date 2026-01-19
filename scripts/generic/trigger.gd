class_name Trigger extends Node3D
## Emits [signal triggered] once when reached by the player.

signal triggered

@export var length: float = 1.0

@onready var player: PlayerAPI = References.player:
	set(value):
		player = value
		player.movement.move.connect(_on_player_move)

var was_triggered: bool = false:
	set(value):
		was_triggered = value
		if was_triggered: triggered.emit()

func update():
	if was_triggered: return
	if is_reached(): was_triggered = true

func is_reached() -> bool:
	var passed_by := global_position.z - player.body.global_position.z
	return passed_by > 0 and passed_by < length

func _on_player_move(step: float):
	if step < 0: return
	update()

func _ready():
	player = player
