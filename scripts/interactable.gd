class_name Interactable extends Node3D

signal removed()
signal hovered()
signal unhovered()
signal cooldown_set(duration: float)
signal cooldown_ended()
signal interacted()

# OVERWRITE ME
func _on_ready(): pass
func _on_remove(): pass
func _on_hover(): pass
func _on_unhover(): pass
func _on_cooldown_set(): pass
func _on_cooldown_end(): pass
func _on_interact(): pass

# GENERAL
@onready var player: PlayerAPI = References.player
@onready var particles: ParticleSystem = References.particles
@export var is_enabled: bool = true
func interact():
	if not is_enabled: return
	if is_on_cooldown: return
	_on_interact()
	if responses_interact: player.dialogue_window.display(
		responses_interact.pick_random())
	if cooldown_seconds > 0: set_on_cooldown()
	interacted.emit()

# CURSOR
@export_group("Cursor")
@onready var player_cursor: PlayerCursor = References.player.cursor
@export var cursor := References.player.cursor.Cursor.INSPECT

# TOOLTIP
@export_group("Tooltip", "tooltip_")
@export var tooltip_action: String = ''
@export var tooltip_key: String = ''
# Option 1: Set a const title / desc
@export var tooltip_title: String:
	get(): return tooltip_title if tooltip_title else _get_tooltip_title()
@export var tooltip_desc: String:
	get(): return tooltip_desc if tooltip_desc else _get_tooltip_desc()
# Option 2: Fill in multiple values to switch between them randomly
@export var tooltip_titles: Array[String] = []
@export var tooltip_descs: Array[String] = []
# Option 3: Use custom getters
func _get_tooltip_title() -> String:
	if not tooltip_titles: return ''
	return tooltip_titles.pick_random()
func _get_tooltip_desc() -> String:
	if not tooltip_descs: return ''
	return tooltip_descs.pick_random()

# ONHOVER
var is_hovered: bool = false
func hover():
	if not is_instance_valid(self): return
	player_cursor.set_state(cursor)
	player_cursor.set_tooltip(tooltip_title, tooltip_desc, tooltip_action,
		tooltip_key)
	is_hovered = true
	_on_hover()
	hovered.emit()
func unhover():
	player_cursor.set_state(player_cursor.Cursor.HIDDEN)
	player_cursor.set_tooltip()
	is_hovered = false
	_on_unhover()
	unhovered.emit()

# RESPONSES
@export_group("Responses", "responses_")
@export var responses_interact: Array[String] = []

# COOLDOWN
@export_group("Cooldown")
@export var cooldown_enabled: bool = true
@export var cooldown_timer: Timer
@export var cooldown_seconds: float = .5
var is_on_cooldown: bool = false:
	set(value):
		if value == is_on_cooldown: return
		is_on_cooldown = value
		if is_on_cooldown:
			_on_cooldown_set()
		else:
			_on_cooldown_end()
			cooldown_ended.emit()
func set_on_cooldown(time: float = cooldown_seconds):
	if not cooldown_enabled: return
	cooldown_timer.start(time)
	is_on_cooldown = true
	cooldown_set.emit(time)
func reset_cooldown():
	cooldown_timer.stop()
	is_on_cooldown = false
func _on_cooldown_timer_timeout():
	is_on_cooldown = false

# READY / REMOVE
func _ready(): _on_ready()
func remove():
	queue_free()
	_on_remove()
	removed.emit()
	unhover()
