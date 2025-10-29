class_name PlayerLantern extends Node

@export var light: InteractiveLight

@export_group("General")
@export var update_rate := 1.0
var update_timer := 0.0

@export_group("Fuel")
@export var fuel := 25.0:
	set(value):
		var fuel_before := fuel
		
		fuel = clampf(value, 0, fuel_limit)
		
		light.intensity = (
			fuel / fuel_limit * (light.max_intensity - light.min_intensity)
			+ light.min_intensity )
		
		var fuel_diff = fuel - fuel_before # Not using abs on purpose
		
		if fuel == 0: extinguish()
		
		elif fuel < 20:
			light.flicker_intensity = 0.3
			light.flicker_min_duration = 0.01
			light.flicker_max_duration = 0.075
		elif fuel < 50:
			light.flicker_intensity = 0.25
			light.flicker_min_duration = 0.05
			light.flicker_max_duration = 0.2
		else:
			light.flicker_intensity = 0.1
			light.flicker_min_duration = 0.1
			light.flicker_max_duration = 0.25
		
		if fuel_bar_delay_timer and fuel_diff > fuel_bar_delay_fuel_threshold:
			fuel_bar_delay_timer.start(fuel_bar_delay_multiplier * fuel_diff)
		logme()
@export var fuel_limit := 100.0:
	set(value):
		if value < 0:
			fuel_limit = 0
		else:
			fuel_limit = value
		fuel = fuel
@export var fuel_depletion_rate_min := 0.25
@export var fuel_depletion_rate_max := 1.75

@export_group("UI")
@export var fuel_bar: ColorRect
var fuel_bar_width := 0.0:
	set(value):
		fuel_bar_width = value
		if fuel_bar:
			fuel_bar.size.x = fuel_bar_width * fuel_bar_scale
			fuel_bar.position.x = (
				(fuel_bar_center_x - fuel_bar.size.x) / 2
				)
@export var fuel_bar_bg: ColorRect
var fuel_bar_bg_width := 0.0:
	set(value):
		fuel_bar_bg_width = value
		if fuel_bar_bg:
			fuel_bar_bg.size.x = fuel_bar_bg_width * fuel_bar_scale
			fuel_bar_bg.position.x = (
				(fuel_bar_center_x - fuel_bar_bg.size.x) / 2
				)
@export var fuel_under_bar: ColorRect
var fuel_under_bar_width := 0.0:
	set(value):
		fuel_under_bar_width = value
		if fuel_under_bar:
			fuel_under_bar.size.x = fuel_under_bar_width * fuel_bar_scale
			fuel_under_bar.position.x = (
				(fuel_bar_center_x - fuel_under_bar.size.x) / 2
				)
@export var fuel_bar_scale := 3.0
@export var fuel_bar_trans_speed := 1.75
@export var fuel_under_bar_trans_speed := 8
var fuel_bar_center_x := 0.0

@export_group("UI Delay")
@export var fuel_bar_delay_timer: Timer
@export var fuel_bar_delay_multiplier := .035
@export var fuel_bar_delay_fuel_threshold := 10
# TODO Should move to FuelBar control node instead

func reignite(intensity: float = -1.0):
	light.is_lit = true
	if intensity > 0: light.intensity = intensity

func extinguish():
	light.is_lit = false

func deplete(how_much: float = -1.0):
	if how_much < 0: how_much = _get_depletion_rate()
	
	fuel -= how_much

func logme():
	print('LANTERN: '+', '.join([
		'F: '+str(fuel)+'/'+str(fuel_limit),
		'I: '+str(light.intensity),
		'DR: '+str(_get_depletion_rate())
	]))

func _get_depletion_rate() -> float:
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

func _update():
	if light.is_lit: deplete()

func _update_ui(delta: float):
	if not fuel_bar: return
	var fuel_trg := (fuel / fuel_limit) * fuel_limit

	if fuel_bar_delay_timer.is_stopped():
		fuel_bar_width = lerp(fuel_bar_width,
			fuel_trg, fuel_bar_trans_speed * delta)
	
	fuel_bar_bg_width = lerp(fuel_bar_bg_width,
		fuel_limit, fuel_bar_trans_speed * delta)
	
	fuel_under_bar_width = lerp(fuel_under_bar_width,
		fuel_trg, fuel_under_bar_trans_speed * delta)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('extinguish'):
		light.is_lit = false

func _ready():
	fuel_limit = fuel_limit

func _process(delta: float):
	if update_timer > 0:
		update_timer -= delta
	else:
		_update()
		update_timer = update_rate
	_update_ui(delta)
