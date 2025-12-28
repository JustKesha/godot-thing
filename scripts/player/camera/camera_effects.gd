class_name PlayerCameraEffects extends Node

@onready var lantern: PlayerLantern = References.player.lantern

@export var head: Node3D
var base_position := Vector3.ZERO
var base_rotation := Vector2.ZERO

@export_group("Screen Shake")
@export var is_screen_shake_on := true # NOTE Does not reset cam position
enum ShakeStrength { OFF = 0, LOW = 15, MILD = 30, MEDIUM = 45, HIGH = 60 }
enum ShakeAmplitude { OFF = 0, LOW = 35, MILD = 30, MEDIUM = 20, HIGH = 15 }
enum ShakeSpeed { OFF = 0, LOW = 75, MILD = 60, MEDIUM = 45, HIGH = 35 }
@export var shake_strength := ShakeStrength.LOW:
	set(value):
		shake_strength = value
		
		match shake_strength:
			ShakeStrength.OFF:
				shake_amplitude = ShakeAmplitude.OFF
				shake_speed = ShakeSpeed.OFF
			ShakeStrength.LOW:
				shake_amplitude = ShakeAmplitude.LOW
				shake_speed = ShakeSpeed.LOW
			ShakeStrength.MILD:
				shake_amplitude = ShakeAmplitude.MILD
				shake_speed = ShakeSpeed.MILD
			ShakeStrength.MEDIUM:
				shake_amplitude = ShakeAmplitude.MEDIUM
				shake_speed = ShakeSpeed.MEDIUM
			ShakeStrength.HIGH:
				shake_amplitude = ShakeAmplitude.HIGH
				shake_speed = ShakeSpeed.HIGH
var shake_amplitude := ShakeAmplitude.LOW
var shake_speed := ShakeSpeed.LOW
var shake_amplitude_divider := 150000.0
var shake_speed_divider := 1000.0
var shake_v_offset_multiplier := 1.7
var shake_h_offset_multiplier := 2.3
var shake_time := 0.0

@export_group("Head Bobbing")
@export var is_head_bobbing_on := true # NOTE Does not reset cam position
@export var bob_speed := 4.5
@export var bob_amplitude := 2.5
@export var bob_smoothness := 5.0
var current_bob_intensity := 0.0
var target_bob_intensity := 0.0
var bob_intensity_threshold := 0.001
var bob_v_multiplier := 1.0
var bob_h_multiplier := 3.0
var bob_time := 0.0

func apply_shake(delta: float):
	if not is_screen_shake_on or shake_strength == 0: return
	
	shake_time += delta * shake_speed * shake_strength/shake_speed_divider
	
	var intensity = shake_amplitude/shake_amplitude_divider * shake_strength
	var shake_rot = Vector2(
		sin(shake_time * shake_v_offset_multiplier) * intensity,
		cos(shake_time * shake_h_offset_multiplier) * intensity
		)
	
	head.rotation.x = base_rotation.x + shake_rot.x
	head.rotation.y = base_rotation.y + shake_rot.y

func apply_bob(delta: float):
	if not is_head_bobbing_on: return
	
	current_bob_intensity = lerp(current_bob_intensity, target_bob_intensity, bob_smoothness * delta)
	if current_bob_intensity < bob_intensity_threshold: return
	
	bob_time += delta * bob_speed
	
	var bob_pos = Vector3(
		sin(bob_time * bob_v_multiplier) * current_bob_intensity / bob_v_multiplier,
		cos(bob_time * bob_h_multiplier) * current_bob_intensity / bob_h_multiplier,
		0.0
	)
	
	head.position = base_position + bob_pos

func _on_player_move(step: float):
	target_bob_intensity = abs(step) * bob_amplitude

func _on_player_stop():
	target_bob_intensity = 0.0

func _on_lantern_updated():
	if not lantern.is_lit:
		shake_strength = ShakeStrength.HIGH
		return
	
	match lantern.fuel_state:
		lantern.FuelState.NONE:
			shake_strength = ShakeStrength.HIGH
		lantern.FuelState.LOW:
			shake_strength = ShakeStrength.MEDIUM
		lantern.FuelState.MID:
			shake_strength = ShakeStrength.MILD
		lantern.FuelState.HIGH, _:
			shake_strength = ShakeStrength.LOW

func _on_lantern_state_changed(is_burning: bool):
	_on_lantern_updated()

func _on_lantern_fuel_changed(_by: float, _current: float):
	_on_lantern_updated()

func _ready():
	if not head: head = $'.'
	
	base_position = head.position
	base_rotation = Vector2(head.rotation.x, head.rotation.y)

func _process(delta: float):
	apply_shake(delta)
	apply_bob(delta)
