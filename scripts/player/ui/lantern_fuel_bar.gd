class_name PlayerFuelBarUI extends Control

@onready var lantern: PlayerLantern = References.player.lantern
@onready var particles: ParticleSystem = References.particles

@export var limit: BarUI
@export var loss: BarUI
@export var fuel: BarUI
@export var fire: BarUI

func _update_limits():
	limit.width_max = lantern.fuel_limit
	fuel.width_max = lantern.fuel_limit
	fire.width_max = lantern.fuel_limit
	loss.width_max = lantern.fuel_limit

func _update():
	if not lantern: return
	fuel.target_width = lantern.fuel
	#fire.target_width = lantern.fuel if lantern.is_lit else 0
	fire.target_width = (
		remap(lantern.light.intensity, lantern.light.min_intensity, lantern.light.max_intensity,
		0, lantern.fuel_limit)
		if lantern.is_lit else 0
		)
	#print(lantern.light.intensity, ' /', lantern.light.max_intensity, ' -> ', fire.target_width)
	loss.target_width = lantern.fuel
	limit.target_width = lantern.fuel_limit if lantern.fuel > 0 else 0

func _on_lantern_fuel_changed(_by: float, _current: float):
	_update()

func _on_lantern_fuel_limit_changed(_new_fuel_limit: float):
	_update_limits()
	_update()

func _on_lantern_state_changed(_is_burning: bool):
	_update()

func _on_delay_timeout():
	particles.spawn(lantern.global_position, particles.Particles.SPARK, lantern)

func _ready():
	_update_limits()
	_update()

func _on_fire_delayed(by: float):
	if lantern.stopppyyy: return
	lantern.light.pause_transition(by)

func _process(delta: float) -> void:
	if lantern.stopppyyy: _update()
