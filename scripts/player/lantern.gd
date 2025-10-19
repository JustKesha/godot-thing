extends Node

@export var light: InteractiveLight
@export var intensity_scroll_speed := 0.25

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('light'):
		light.is_lit = not light.is_lit
	
	elif event.is_action_pressed('light_up'):
		light.intensity += intensity_scroll_speed
	
	elif event.is_action_pressed('light_down'):
		light.intensity -= intensity_scroll_speed
