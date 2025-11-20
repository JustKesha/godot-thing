class_name PlayerMovementController extends Node

signal move(step: float)
signal stop(traveled: float)

@export var speed: float = 3.25
@export var action: String = "move"

var is_moving: bool = false:
	set(value):
		if value == is_moving: return
		is_moving = value
var distance_traveled: float = 0.0
var current_speed: float = 0.0:
	get(): return self.get_physics_process_delta_time() * speed

func walk(step: float = current_speed):
	is_moving = true
	distance_traveled += step
	move.emit(step)

func rest():
	if not is_moving: return
	is_moving = false
	stop.emit(distance_traveled)

func _physics_process(_delta: float):
	if Input.is_action_pressed(action): walk()
	else: rest()
