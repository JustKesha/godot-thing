class_name BarUI extends ColorRect

signal delayed(by: float)

@export_group("Size & Positioning")
@export var is_centered := false
@export var width_scale := 1.0
@export var width_min := 0.0
@export var width_max := 100.0

@export_group("Transition")
@export var transition_speed := 5.0

@export_group("Delay")
@export var delay_enabled := false
@export var delay_timer: Timer
@export var delay_on_increase := true
@export var delay_on_decrease := true
@export var delay_width_threshold := 5.0
@export var delay_time_multiplier := 0.01
@export var delay_time_limit := 0.75

var fill_percentage := 0.0:
	set(value):
		fill_percentage = clampf(value, 0.0, 100.0)
		target_width = width_min + (width_max - width_min) * (fill_percentage / 100.0)
var target_width := -1.0:
	set(value):
		if value == target_width: return
		
		var old_target_width = target_width
		target_width = clampf(value, width_min, width_max)
		var diff = target_width - old_target_width
		
		if( abs(diff) > delay_width_threshold and delay_enabled and delay_timer
			and (delay_on_increase and diff > 0 or delay_on_decrease and diff < 0) ):
			# TODO Add a remap util remap(a,a_min,a_max,b_min,b_max) -> b
			var delay = (
				(abs(diff) * delay_time_multiplier - delay_width_threshold)
				/ (width_max * delay_time_multiplier - delay_width_threshold)
				* delay_time_limit )
			delay_timer.start(delay)
			delayed.emit(delay)
var is_target_width_reached: bool:
	get(): return is_equal_approx(width, target_width)
var width := 0.0:
	set(value):
		width = clampf(value, width_min, width_max)
		self.size.x = width * width_scale
		if is_centered:
			self.position.x = -self.size.x/2

func _process(delta: float):
	if is_target_width_reached: return
	if delay_enabled and not delay_timer.is_stopped(): return
	width = lerp(width, target_width, transition_speed * delta)

func _ready():
	target_width = 0
