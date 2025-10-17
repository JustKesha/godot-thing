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
			_current_intensity = 0.0
			extinguished.emit()

@export_group("Intensity")
@export var intensity := 4.0:
	set(value):
		intensity = clamp(value, min_intensity, max_intensity)
		intensity_changed.emit(intensity)
@export var min_intensity := 1.0
@export var max_intensity := 6.0
@export var energy_multiplier := 0.3
@export var radius_multiplier := 2.7

@export_group("Transition")
@export var intensity_decrease_speed := 5.0
@export var intensity_increase_speed := 6.0
var _current_intensity := intensity:
	set(value):
		_current_intensity = value
		_update()
var _intensity_snap_threshold := 0.005

func _update():
	var lit_multiplier := 1 if is_lit else 0
	light_energy = _current_intensity * energy_multiplier * lit_multiplier
	omni_range = _current_intensity * radius_multiplier

func _transition(delta: float):
	if not is_lit: return
	if _current_intensity == intensity: return
	
	if abs(_current_intensity - intensity) <= _intensity_snap_threshold:
		_current_intensity = intensity
		return
	
	var transition_speed = (
		intensity_increase_speed if _current_intensity < intensity
		else intensity_decrease_speed
	)
	
	_current_intensity = lerp(_current_intensity,
		intensity, delta * transition_speed)

func _ready():
	intensity = intensity
	_update()

func _process(delta: float):
	_transition(delta)
