class_name PlayerMovementController extends Node

signal move()
signal stop()

@export var world: WorldGenerator

func _physics_process(delta: float):
	if Input.is_action_pressed('move'):
		Stats.is_moving = true
		world.move(delta)
		move.emit()
		Stats.distance_traveled += Stats.speed
	elif Stats.is_moving:
		Stats.is_moving = false
		stop.emit()
