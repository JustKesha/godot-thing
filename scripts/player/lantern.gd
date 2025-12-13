class_name PlayerLantern extends Node3D

@onready var particles: ParticleSystem = References.particles

@export var light: InteractiveLight
var debug_info: String:
	get(): return 'LANTERN: '+', '.join([
		'F: '+str(fuel)+'/'+str(fuel_limit),
		'I: '+str(light.intensity),
		'DR: '+str(fuel_depletion_rate)
	])

@export_group("Fuel")
@export var fuel := 40.0:
	set(value):
		var fuel_before := fuel
		fuel = clampf(value, 0, fuel_limit)
		light.intensity = (
			fuel / fuel_limit * (light.max_intensity - light.min_intensity)
			+ light.min_intensity )
		var fuel_diff = fuel - fuel_before
		
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
		
		if fuel_bar_delay_timer and fuel_diff > fuel_bar_delay_threshold:
			# TODO Add a remap util remap(a,a_min,a_max,b_min,b_max) -> b
			var fuel_bar_delay = (
				(fuel_bar_delay_multiplier * fuel_diff
					- fuel_bar_delay_threshold)
				/ (fuel_bar_delay_multiplier * fuel_limit
					- fuel_bar_delay_threshold)
				* fuel_bar_delay_max
			)
			fuel_bar_delay_timer.start(fuel_bar_delay)
			particles.spawn(self.global_position, particles.Particles.SPARK, self)
		Logger.write(debug_info)
@export var fuel_limit := 100.0:
	set(value):
		if value < 0:
			fuel_limit = 0
		else:
			fuel_limit = value
		fuel = fuel

@export_group("Depletion")
@export var update_timer: Timer
@export var update_rate := 1.0:
	set(value):
		update_rate = value
		if update_timer:
			update_timer.wait_time = update_rate
			if update_timer.time_left > update_rate: update_timer.start()
@export var fuel_depletion_rate: float = -1.0:
	get():
		if fuel_depletion_rate >= 0: return fuel_depletion_rate
			
		var normalized_intensity = (
			( light.intensity - light.min_intensity )
			/ ( light.max_intensity - light.min_intensity )
		)
		return (
			normalized_intensity
			* (fuel_depletion_rate_max - fuel_depletion_rate_min)
			+ fuel_depletion_rate_min
		)
@export var fuel_depletion_rate_min := 0.25
@export var fuel_depletion_rate_max := 2.75

@export_group("Controls")
@export var extinguish_action: String = 'extinguish'

@export_group("UI")
@export var fuel_bar_scale := 3.0
@export var fuel_bar: ColorRect
@export var fuel_bar_trans_speed := 10.75
@export var fuel_bar_delay_timer: Timer
@export var fuel_bar_delay_threshold := 10
@export var fuel_bar_delay_multiplier := .035
@export var fuel_bar_delay_max := 0.75
var fuel_bar_width := 0.0:
	set(value):
		fuel_bar_width = value
		if fuel_bar:
			fuel_bar.size.x = fuel_bar_width * fuel_bar_scale
			fuel_bar.position.x = -fuel_bar.size.x/2
@export var fuel_bar_bg: ColorRect
@export var fuel_bar_bg_trans_speed := 3.0
var fuel_bar_bg_width := 0.0:
	set(value):
		fuel_bar_bg_width = value
		if fuel_bar_bg:
			fuel_bar_bg.size.x = fuel_bar_bg_width * fuel_bar_scale
			fuel_bar_bg.position.x = -fuel_bar_bg.size.x/2
@export var fuel_under_bar: ColorRect
@export var fuel_under_bar_trans_speed := 8
var fuel_under_bar_width := 0.0:
	set(value):
		fuel_under_bar_width = value
		if fuel_under_bar:
			fuel_under_bar.size.x = fuel_under_bar_width * fuel_bar_scale
			fuel_under_bar.position.x = -fuel_under_bar.size.x/2

# ACTIONS

## Depletes given amount of fuel, if amount <0 will use fuel_depletion_rate.
func deplete(how_much: float = -1.0):
	if how_much < 0: how_much = fuel_depletion_rate
	fuel -= how_much

## Refills given amount of fuel, if amount <0 will max out the fuel.
func refill(how_much: float = -1.0):
	if how_much < 0: how_much = fuel_limit
	fuel += how_much

func extinguish():
	light.is_lit = false

func reignite(intensity: float = -1.0):
	light.is_lit = true
	particles.spawn(self.global_position, particles.Particles.SPARK, self)
	if intensity > 0: light.intensity = intensity

# GENERAL

func _update():
	if light.is_lit: deplete()

func _update_ui(delta: float):
	if not fuel_bar: return
	var fuel_trg := (fuel / fuel_limit) * fuel_limit

	if fuel_bar_delay_timer.is_stopped():
		fuel_bar_width = lerp(fuel_bar_width,
			fuel_trg, fuel_bar_trans_speed * delta)
	
	fuel_bar_bg_width = lerp(fuel_bar_bg_width,
		fuel_limit, fuel_bar_bg_trans_speed * delta)
	
	fuel_under_bar_width = lerp(fuel_under_bar_width,
		fuel_trg, fuel_under_bar_trans_speed * delta)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(extinguish_action): extinguish()

func _ready():
	update_rate = update_rate
	
func _process(delta: float):
	_update_ui(delta)

func _on_update_timeout():
	_update()
