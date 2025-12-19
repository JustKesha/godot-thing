class_name PlayerLantern extends Node3D

@onready var particles: ParticleSystem = References.particles

signal state_changed(is_burning: bool)
signal extinguished()
signal reignited()
signal fuel_changed(by: float, current: float)
signal fuel_increased(by: float, current: float)
signal fuel_decreased(by: float, current: float)
signal fuel_limit_changed(new_fuel_limit: float)

@export_group("General")
@export var light: InteractiveLight
@onready var is_lit := light.is_lit:
	set(value):
		if light.is_lit == value: return
		
		light.is_lit = value
		is_lit = light.is_lit
		
		state_changed.emit(is_lit)
		if is_lit:
			particles.spawn(self.global_position, particles.Particles.SPARK, self)
			reignited.emit()
		else:
			extinguished.emit()

@export_group("Fuel")
@export var fuel := 40.0:
	set(value):
		var fuel_before := fuel
		fuel = clampf(value, 0, fuel_limit)
		var fuel_diff = fuel - fuel_before
		
		if fuel_diff != 0:
			fuel_changed.emit(fuel_diff, fuel)
			if fuel_diff > 0:
				fuel_increased.emit(abs(fuel_diff), fuel)
			else:
				fuel_decreased.emit(abs(fuel_diff), fuel)
@export var fuel_limit := 100.0:
	set(value):
		if value < 0:
			fuel_limit = 0
		else:
			fuel_limit = value
		fuel = fuel
		fuel_limit_changed.emit(fuel_limit)

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

# ACTIONS

## Depletes given amount of fuel, if amount <0 will use fuel_depletion_rate.
func deplete(how_much: float = -1.0):
	if how_much < 0: how_much = fuel_depletion_rate
	fuel -= how_much

## Refills given amount of fuel, if amount <0 will max out the fuel.
func refill(amount: float = -1.0):
	if amount < 0: amount = fuel_limit
	fuel += amount

func extinguish():
	is_lit = false

func reignite():
	is_lit = true

# GENERAL

func _on_update_timeout():
	if light.is_lit: deplete()

func _on_fuel_changed(by: float, current: float):
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
	
	light.intensity = (
		fuel / fuel_limit * (light.max_intensity - light.min_intensity)
		+ light.min_intensity )
	
	Logger.write(debug_info)

func _ready():
	update_rate = update_rate
	fuel = fuel

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(extinguish_action): extinguish()

var debug_info: String:
	get(): return 'LANTERN: '+', '.join([
		'F: '+str(fuel)+'/'+str(fuel_limit),
		'I: '+str(light.intensity),
		'DR: '+str(fuel_depletion_rate)
	])
