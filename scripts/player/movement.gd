class_name PlayerMovementController extends Node

signal move(speed: float, delta: float)
signal stop(distance_traveled: float)

@export var world: WorldGenerator
@export var speed := 3.25
@export var distance_traveled := 0.0
var is_moving := false

func _physics_process(delta: float):
	if Input.is_action_pressed('move'):
		is_moving = true
		world.move(speed * delta)
		move.emit(speed, delta)
		distance_traveled += speed
	elif is_moving:
		is_moving = false
		stop.emit(distance_traveled)
