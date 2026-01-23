class_name Effect extends Node3D

func _on_apply(): pass
func _on_remove(): pass
func _on_tick(tps: float): pass

signal applied()
signal removed()
signal ticked(tps: float)

@onready var player := References.player

var effect_id: String ## WARNING Auto-Assigned in [method Effects.get_by_id].
var effect_name: String ## WARNING Auto-Assigned in [method Effects.get_by_id].
var effect_desc: String ## WARNING Auto-Assigned in [method Effects.get_by_id].
var effect_type: Effects.Type ## WARNING Auto-Assigned in [method Effects.get_by_id].

@export var apply_on_ready: bool = true
var is_active: bool = false:
	set(value):
		if is_active == value and not is_active: return # Allows to refresh active state
		is_active = value
		
		if is_active:
			duration_timer.start()
			tick_timer.start()
			
			_on_apply()
			applied.emit()
			Logger.write('EFFECT: ' + effect_id + 'x' + str(stack) + ' APPLIED FOR ' + str(duration_timer.wait_time) + ' SECONDS')
		else:
			duration_timer.stop()
			tick_timer.stop()
			queue_free()
			
			_on_remove()
			removed.emit()
			Logger.write('EFFECT: ' + effect_id + ' REMOVED')

@export_group("Tick", "tick_")
@export var tick_interval: float = 0.25:
	set(value):
		tick_interval = value
		if tick_timer:
			tick_timer.wait_time = tick_interval
@export var tick_timer: Timer:
	set(value):
		tick_timer = value
		tick_timer.one_shot = false
		tick_timer.autostart = false
		tick_timer.wait_time = tick_interval
		tick_timer.stop()
		tick_timer.timeout.connect(tick)
var ticks_per_second: float:
	set(value): tick_interval = 1.0 / value
	get(): return 1 / tick_interval

@export_group("Stack", "stack_")
@export var stack_min: int = 1
@export var stack_max: int = 32
var stack: int = stack_min:
	set(value):
		stack = clamp(value, stack_min, stack_max)

@export_group("Duration", "duration_")
@export var duration_default: float = 1.0
@export var duration_timer: Timer:
	set(value):
		duration_timer = value
		duration_timer.one_shot = false
		duration_timer.autostart = false
		duration_timer.stop()
		duration_timer.timeout.connect(remove)

# HELPERS

enum DurationApplyMode { HARD_SET, SOFT_SET, ADD }

func set_duration(duration: float = duration_default,
	mode := DurationApplyMode.SOFT_SET):
	var time_left := duration_timer.time_left
	
	match mode:
		DurationApplyMode.HARD_SET:
			duration_timer.wait_time = duration
		
		DurationApplyMode.SOFT_SET, _:
			if duration > time_left:
				duration_timer.wait_time = duration
		
		DurationApplyMode.ADD:
			duration_timer.wait_time = duration + time_left

func set_stack(new_stack: int):
	stack = new_stack

# ACTIONS

func apply(duration: float = duration_default, stack_add: int = 0,
	duration_apply_mode := DurationApplyMode.SOFT_SET):
	set_duration(duration, duration_apply_mode)
	set_stack(stack + stack_add)
	is_active = true

func remove():
	is_active = false

func tick():
	_on_tick(ticks_per_second)
	ticked.emit(ticks_per_second)

# GENERAL

func _ready():
	if apply_on_ready: apply()
