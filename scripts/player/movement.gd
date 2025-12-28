class_name PlayerMovementController extends Node

signal move(step: float)
signal stop(traveled: float)

@export var speed := 3.25
@export var action := 'move'
var is_moving := false:
	set(value):
		if value == is_moving: return
		is_moving = value
var distance_traveled := 0.0
var current_speed := 0.0:
	get(): return self.get_physics_process_delta_time() * speed

## NOTE Read only, use lock & unlock methods instead
var is_locked: bool:
	get(): return not locked_by.is_empty()
var locked_by := []

func walk(step: float = current_speed):
	if is_locked: return
	is_moving = true
	distance_traveled += step
	move.emit(step)

func stop_walking():
	if not is_moving: return
	is_moving = false
	stop.emit(distance_traveled)

func lock(source: String):
	if locked_by.has(source): return
	locked_by.append(source)
	stop_walking()

func unlock(source: String):
	locked_by.erase(source)

func _physics_process(_delta: float):
	if Input.is_action_pressed(action): walk()
	else: stop_walking()
