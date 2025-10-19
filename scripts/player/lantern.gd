extends Node

@export var light: InteractiveLight

@export_group("General")
@export var intensity_change_rate := 0.65
@export var update_rate := 1.0
var update_timer := 0.0

@export_group("Fuel")
@export var fuel := 75.0:
	set(value):
		fuel = clampf(value, 0, fuel_limit)
		if fuel == 0: extinguish()
		
		elif fuel < 20:
			light.flicker_intensity = 0.6
			light.flicker_min_duration = 0.05
			light.flicker_max_duration = 0.15
		elif fuel < 50:
			light.flicker_intensity = 0.3
			light.flicker_min_duration = 0.05
			light.flicker_max_duration = 0.25
		else:
			light.flicker_intensity = 0.1
			light.flicker_min_duration = 0.2
			light.flicker_max_duration = 0.4
@export var fuel_limit := 100.0
@export var fuel_depletion_rate_min := 0.15
@export var fuel_depletion_rate_max := 0.75

func lightup(intensity: float = -1.0):
	light.is_lit = true
	if intensity > 0: light.intensity = intensity

func extinguish():
	light.is_lit = false

func change_intensity(dir: float,
	strength: float = intensity_change_rate) -> float:
	light.intensity += dir * strength
	return light.intensity

func deplete(how_much: float = -1.0):
	if how_much < 0:
		how_much = get_depletion_rate()
	
	fuel -= how_much
	print('LANTERN F: ',fuel,'%, I: ',light.intensity,' DR: ',how_much)

func get_depletion_rate() -> float:
	var normalized_intensity = (
		( light.intensity - light.min_intensity )
		/ ( light.max_intensity - light.min_intensity )
	)
	var depletion_rate = (
		normalized_intensity
		* (fuel_depletion_rate_max - fuel_depletion_rate_min)
		+ fuel_depletion_rate_min
	)
	return depletion_rate

func update():
	if light.is_lit: deplete()

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
