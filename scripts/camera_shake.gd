class_name PlayerCameraEffects extends Node

@export var head: Node3D
var base_position := Vector3.ZERO
var base_rotation := Vector2.ZERO

@export_group("Screen Shake")
enum ShakeStrength { OFF = 0, LOW = 15, MILD = 40, MEDIUM = 75, HIGH = 100 }
@export var shake_strength: float = ShakeStrength.LOW
@export var shake_amplitude := 3.5
@export var shake_speed := 0.75
var shake_amplitude_divider := 15000
var shake_speed_divider := 10
var shake_v_offset_multiplier := 1.7
var shake_h_offset_multiplier := 2.3
var shake_time := 0.0

@export_group("Head Bobbing")
@export var bob_speed := 4.5
@export var bob_amplitude := 0.045
@export var bob_smoothness := 5.0
var current_bob_intensity := 0.0
var target_bob_intensity := 0.0
var bob_intensity_threshold := 0.001
var bob_v_multiplier := 1.0
var bob_h_multiplier := 3.0
var bob_time := 0.0

func apply_shake(delta: float):
	if shake_strength == 0: return
	
	shake_time += delta * shake_speed * shake_strength/shake_speed_divider
	
	var intensity = shake_amplitude/shake_amplitude_divider * shake_strength
	var shake_rot = Vector2(
		sin(shake_time * shake_v_offset_multiplier) * intensity,
		cos(shake_time * shake_h_offset_multiplier) * intensity
		)
	
	head.rotation.x = base_rotation.x + shake_rot.x
	head.rotation.y = base_rotation.y + shake_rot.y

func apply_bob(delta: float):
	current_bob_intensity = lerp(current_bob_intensity, target_bob_intensity, bob_smoothness * delta)
	if current_bob_intensity < bob_intensity_threshold: return
	
	bob_time += delta * bob_speed
	
	var bob_pos = Vector3(
		sin(bob_time * bob_v_multiplier) * current_bob_intensity / bob_v_multiplier,
		cos(bob_time * bob_h_multiplier) * current_bob_intensity / bob_h_multiplier,
		0.0
	)
	
	head.position = base_position + bob_pos

func _on_player_move():
	# Might be better to use distance traveled instead
	target_bob_intensity = Stats.speed * bob_amplitude

func _on_player_stop():
	target_bob_intensity = 0.0

func _ready():
	if not head: head = $'.'
	
	base_position = head.position
	base_rotation = Vector2(head.rotation.x, head.rotation.y)

func _process(delta: float):
	apply_shake(delta)
	apply_bob(delta)
