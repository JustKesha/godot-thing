extends Node

@export var is_enabled: bool = false

func write(message: String):
	if not is_enabled: return
	print(message)
