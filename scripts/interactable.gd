class_name Interactable extends Node

# GENERAL
@export var is_enabled: bool = true
func _on_interact(_player: PlayerAPI): pass
func interact(_player: PlayerAPI):
	if not is_enabled: return
	if is_on_cooldown: return
	_on_interact(_player)
	if cooldown_seconds > 0: set_on_cooldown()

# COOLDOWN
func _on_cooldown_set(): pass
func _on_cooldown_end(): pass
@export_group("Cooldown")
@export var cooldown_timer: Timer
@export var cooldown_seconds: float = .5
@export var cooldown_enabled: bool = true
var is_on_cooldown: bool = false:
	set(value):
		if value == is_on_cooldown: return
		is_on_cooldown = value
		if is_on_cooldown: _on_cooldown_set()
		else: _on_cooldown_end()

func set_on_cooldown(time: float = cooldown_seconds):
	if not cooldown_enabled: return
	cooldown_timer.start(time)
	is_on_cooldown = true
func reset_cooldown():
	cooldown_timer.stop()
	is_on_cooldown = false

func _on_cooldown_timer_timeout():
	is_on_cooldown = false

# READY / REMOVE
func _on_interactable_ready(): pass
func _on_remove(): pass
func _ready(): _on_interactable_ready()
func remove():
	_on_remove()
	queue_free()

# ONHOVER
func _on_hover(): pass
func _on_unhover(): pass
func hover(): _on_hover()
func unhover(): _on_unhover()

# INFO POPUP
@export_group("Info Popup")
# Option 1: Set a const title / desc
@export var info_title: String:
	get(): return info_title if info_title else _get_info_title()
@export var info_desc: String:
	get(): return info_desc if info_desc else _get_info_desc()

# Option 2: Fill in multiple values to switch between them randomly
@export var info_titles: Array[String] = []
@export var info_descs: Array[String] = []

# Option 3: Use custom getters
func _get_info_title() -> String:
	if not info_titles: return ''
	return info_titles.pick_random()
func _get_info_desc() -> String:
	if not info_descs: return ''
	return info_descs.pick_random()
