class_name InteractiveLight extends OmniLight3D

signal intensity_changed
signal extinguished
signal reignited

@export var is_lit := true:
	set(value):
		if is_lit == value:
			return
		is_lit = value
		_update()
		if is_lit:
			reignited.emit()
		else:
			extinguished.emit()

@export_group("Intensity")
@export var intensity := 4.0:
	set(value):
		intensity = clamp(value, min_intensity, max_intensity)
		_update()
		intensity_changed.emit(intensity)
@export var min_intensity := 1.0
@export var max_intensity := 6.0
@export var energy_multiplier := 0.2
@export var radius_multiplier := 1.8

func _update():
	var lit_multiplier := 1 if is_lit else 0
	light_energy = intensity * energy_multiplier * lit_multiplier
	omni_range = intensity * radius_multiplier

func _ready():
	intensity = intensity
