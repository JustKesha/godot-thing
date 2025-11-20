extends Node

@export var is_enabled: bool = true

func write(message: String):
	if not is_enabled: return
	print(message)
