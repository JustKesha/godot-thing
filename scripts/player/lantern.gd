extends Node

@export var light: InteractiveLight

@export_group("General")
@export var intensity_change_rate := 0.45
@export var update_rate := 1.0
var update_timer := 0.0

@export_group("Fuel")
@export var fuel := 75.0:
	set(value):
		fuel = clampf(value, 0, fuel_limit)
		if fuel == 0:
			light.is_lit = false
@export var fuel_limit := 100.0
@export var fuel_deplition_rate := 3.5

func lightup(intensity: float = -1.0):
	light.is_lit = true
	if intensity > 0: light.intensity = intensity

func extinguish():
	light.is_lit = false

func change_intensity(dir: float, strength: float = intensity_change_rate) -> float:
	light.intensity += dir * strength
	return light.intensity

func deplete(how_much: float = fuel_deplition_rate):
	if not light.is_lit: return
	fuel -= how_much
	print('LANTERN F:',fuel,'%, DR:',fuel_deplition_rate)

func update():
	deplete()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('light'):
		light.is_lit = not light.is_lit
	
	elif event.is_action_pressed('light_up'):
		change_intensity(1)
	elif event.is_action_pressed('light_down'):
		change_intensity(-1)

func _process(delta: float):
	if update_timer > 0:
		update_timer -= delta
	else:
		update()
		update_timer = update_rate
