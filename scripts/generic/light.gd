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
@export var intensity := 3.0:
	set(value):
		var before = intensity
		
		intensity = clampf(value, min_intensity, max_intensity)
		intensity_transition_speed = (
			intensity_increase_speed if intensity > _current_intensity
			else intensity_decrease_speed )
		
		if intensity != before:
			intensity_changed.emit(intensity)
@export var min_intensity := 1.0:
	set(value):
		min_intensity = value
		if min_intensity > max_intensity:
			min_intensity = max_intensity
		_awake()
@export var max_intensity := 8.0:
	set(value):
		max_intensity = value
		if max_intensity < min_intensity:
			max_intensity = min_intensity
		_awake()
@export var energy_multiplier := 0.25:
	set(value):
		energy_multiplier = value
		_update()
@export var radius_multiplier := 1.5:
	set(value):
		radius_multiplier = value
		_update()

@export_group("Transition")
@export var transition_pause_timer: Timer
@export var intensity_increase_speed := 2.0
@export var intensity_decrease_speed := 4.0
var is_transition_paused: bool:
	get(): return not transition_pause_timer.is_stopped()
var intensity_transition_speed := intensity_increase_speed
var _current_intensity := intensity:
	set(value):
		_current_intensity = value
		_update()
var _intensity_snap_threshold := 0.005

@export_group("Halo")
@export var create_halo := false:
	set(value):
		create_halo = value
		if create_halo: _create_halo()
		else: _remove_halo()
@export var halo_energy_multiplier := 0.25
@export var halo_radius_multiplier := 0.75
@export var halo_fog_multiplier := 3.0
var _halo: OmniLight3D

@export_group("Flickering")
@export var flicker_intensity := 0.15
@export var flicker_transition := 6.5
@export var flicker_min_duration := 0.1
@export var flicker_max_duration := 0.3
var _flicker_target_intensity := 0.0
var _flicker_current_intensity := 0.0
var _flicker_timer := 0.0

func _update():
	var lit_multiplier := 1 if is_lit else 0
	var fact_intensity := _current_intensity + _flicker_current_intensity
	
	light_energy = fact_intensity * energy_multiplier * lit_multiplier
	omni_range = fact_intensity * radius_multiplier
	
	if _halo:
		_halo.light_energy = fact_intensity * halo_energy_multiplier
		_halo.omni_range = fact_intensity * halo_radius_multiplier
		_halo.light_volumetric_fog_energy = fact_intensity * halo_fog_multiplier

func pause_transition(pause_duration: float):
	transition_pause_timer.start(pause_duration)

func _transition(delta: float):
	if not is_lit: return
	if _current_intensity == intensity: return
	if is_transition_paused: return
	
	if abs(_current_intensity - intensity) <= _intensity_snap_threshold:
		_current_intensity = intensity
		return
	
	_current_intensity = lerp(_current_intensity,
		intensity, delta * intensity_transition_speed)

func _flicker(delta: float):
	if flicker_intensity <= 0.0:
		_flicker_current_intensity = 0.0
		return
	
	_flicker_timer -= delta
	if _flicker_timer <= 0:
		_flicker_target_intensity = randf_range(-flicker_intensity, flicker_intensity)
		_flicker_timer = randf_range(flicker_min_duration, flicker_max_duration)
	
	_flicker_current_intensity = lerp(_flicker_current_intensity,
		_flicker_target_intensity, delta * flicker_transition)
	
	_update()

func _create_halo():
	if _halo: return
	
	_halo = OmniLight3D.new()
	_halo.light_color = light_color
	add_child(_halo)
	
	_update()

func _remove_halo():
	if not _halo: return
	
	_halo.queue_free()
	_halo = null

func _awake():
	intensity = intensity

func _ready():
	_awake()
	if create_halo: _create_halo()
	if not transition_pause_timer:
		transition_pause_timer = Timer.new()
		transition_pause_timer.one_shot = true
		self.add_child(transition_pause_timer)
	_update()

func _process(delta: float):
	_transition(delta)
	_flicker(delta)
