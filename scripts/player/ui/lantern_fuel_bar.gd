class_name PlayerFuelBarUI extends Control

@onready var particles: ParticleSystem = References.particles

@export var lantern: PlayerLantern
@export var limit: BarUI
@export var loss: BarUI
@export var fuel: BarUI
@export var fire: BarUI

func _update_limits():
	limit.target_width = lantern.fuel_limit
	fuel.width_max = lantern.fuel_limit
	fire.width_max = lantern.fuel_limit
	loss.width_max = lantern.fuel_limit

func _update():
	fuel.target_width = lantern.fuel
	fire.target_width = lantern.fuel if lantern.is_lit else 0
	loss.target_width = lantern.fuel

func _on_lantern_fuel_changed(_by: float, _current: float):
	_update()

func _on_lantern_fuel_limit_changed(_new_fuel_limit: float):
	_update_limits()

func _on_lantern_state_changed(_is_burning: bool):
	_update()

func _on_delay_timeout():
	particles.spawn(lantern.global_position, particles.Particles.SPARK, lantern)

func _ready():
	_update_limits()
	_update()
