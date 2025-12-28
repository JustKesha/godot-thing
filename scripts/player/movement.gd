class_name PlayerMovementController extends Node

@onready var dialogue_window := References.player.dialogue_window

signal move(step: float)
signal stop()
signal backward_travel_limit_reached()

@export_group("General")
@export var speed: float = 3.25
@export var action_forward: String = 'forward'
@export var action_backward: String = 'backward'

@export_group("Backward Travel Limit")
@export var backward_travel_limit: float = 10.0
@export var backward_travel_limit_responses: Array[String] = ['...']
var is_backward_travel_limit_reached: bool:
	get(): return (
		current_distance_traveled < 0
		or total_distance_traveled - current_distance_traveled > backward_travel_limit
	)

var is_moving := false
var total_distance_traveled := 0.0
var current_distance_traveled := 0.0

## NOTE Read only, use lock & unlock methods instead
var is_locked: bool:
	get(): return not locked_by.is_empty()
var locked_by := []

# ACTIONS

func walk(step: float):
	if is_locked: return
	if step == 0: return
	if step < 0 and is_backward_travel_limit_reached:
		if backward_travel_limit_responses:
			dialogue_window.display(backward_travel_limit_responses.pick_random())
		backward_travel_limit_reached.emit()
		stop_walking()
		return
	
	current_distance_traveled += step
	if current_distance_traveled > total_distance_traveled:
		total_distance_traveled = current_distance_traveled
	
	is_moving = true
	move.emit(step)

func stop_walking():
	if not is_moving: return
	is_moving = false
	stop.emit()

func lock(source: String):
	if locked_by.has(source): return
	locked_by.append(source)
	stop_walking()

func unlock(source: String):
	locked_by.erase(source)

# GENERAL

func _physics_process(delta: float):
	if Input.is_action_pressed(action_forward):
		walk(speed * delta)
	elif Input.is_action_pressed(action_backward):
		walk(-speed * delta)
	else:
		stop_walking()
