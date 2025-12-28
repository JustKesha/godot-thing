class_name PlayerCameraController extends Node

@onready var player: PlayerAPI = References.player

@export var camera: Camera3D
@export var trypod: Node3D

@export_group("General")
@export var sensitivity := 50.0
@export var turn_rate := 15.0
@export var mouse_mode := Input.MOUSE_MODE_CAPTURED
@export var h_sensitivity := 1.0
@export var h_min := -2.0
@export var h_max := 2.0
@export var v_sensitivity := 1.0
@export var v_min := -0.95
@export var v_max := 0.85
var sensitivity_divider := 100000.0

@export var is_user_input_on := true
var is_rotating := false

@export_group("Target Lock")
@export var is_target_locked := false:
	set(value):
		is_target_locked = value
		if is_target_locked: player.lock("camera_locked")
		else: player.unlock("camera_locked")
@export var lock_turn_rate := 3.5
@export var lock_object: Node3D = null:
	set(value):
		if value is Node3D:
			lock_object = value
			is_target_locked = true
		else:
			lock_object = null
			is_target_locked = false
@export var lock_position := Vector3.ZERO:
	set(value):
		if value or is_target_locked:
			lock_position = value
			is_target_locked = true
		else:
			lock_position = Vector3.ZERO
			is_target_locked = false
@export var lock_angle := Vector2.ZERO:
	set(value):
		if value or is_target_locked:
			lock_angle = value
			is_target_locked = true
		else:
			lock_angle = Vector2.ZERO
			is_target_locked = false
@export var lock_timer: Timer
var lock_start_angle := Vector2.ZERO
var lock_keep_angle := false:
	set(value):
		lock_keep_angle = value
		if not lock_keep_angle:
			lock_start_angle = get_camera_angle()
var lock_await_goal := false

var target_x_rotation := 0.0:
	set(value):
		if is_target_locked:
			target_x_rotation = value
		else:
			target_x_rotation = clamp(value, v_min, v_max)
		is_rotating = true
var target_y_rotation := 0.0:
	set(value):
		if is_target_locked:
			target_y_rotation = value
		else:
			target_y_rotation = clamp(value, h_min, h_max)
		is_rotating = true

# ACTIONS

## Wrapper for lock method
func face(where: Variant):
	lock(where, 2.0, true, true)

## Wrapper for lock method
## NOTE The [param duration] determines the total number of seconds for which
## the player's free camera movement is obstructed (including turn time),
## not how long the player will face the target.
func look(at: Variant, duration: float = 1.75, reset_after: bool = true):
	lock(at, duration, false, false)
	if reset_after: lock_start_angle = Vector2.ZERO

## [param objective] can be a [Vector2] camera angle, [Vector3] world position
## or a [Node3D] object to lock onto. Use [param duration] [param -1] to lock
## until manually reset. When [param auto_unlock] is [param true], will
## reset once the [param objective] condition is reached. Using seconds.
func lock(objective: Variant, timeout: float = -1.0, auto_unlock: bool = false,
	keep_angle: bool = false ):
	is_target_locked = true
	lock_keep_angle = keep_angle
	lock_await_goal = auto_unlock
	
	if objective is Vector2: lock_angle = objective
	elif objective is Vector3: lock_position = objective
	elif objective is Node3D: lock_object = objective
	
	if timeout > 0: lock_timer.start(timeout)
	else: lock_timer.stop()

func unlock():
	lock_object = null
	lock_position = Vector3.ZERO
	lock_angle = Vector2.ZERO
	lock_await_goal = false
	lock_timer.stop()
	if not lock_keep_angle: lock(lock_start_angle, 1.5, true, true)
	else: awake()

# HELPERS

func get_camera_angle() -> Vector2:
	return Vector2(camera.rotation.x, trypod.rotation.y)

func is_at_target_rotation(error_margin: float = 0.025) -> bool:
	# TODO Couldnt find a way to use custom weight for is_zero_approx
	var rotation = get_camera_angle()
	return ( abs(rotation.x - target_x_rotation) <= error_margin
		 and abs(rotation.y - target_y_rotation) <= error_margin )

func awake():
	var angle = get_camera_angle()
	target_x_rotation = angle.x
	target_y_rotation = angle.y

# GENERAL

func _ready():
	if not camera: camera = $'.'
	if not trypod: trypod = get_parent()
	if not lock_timer:
		lock_timer = Timer.new()
		lock_timer.one_shot = true
		lock_timer.timeout.connect(unlock)
		add_child(lock_timer)
	
	target_x_rotation = camera.rotation.x
	target_y_rotation = trypod.rotation.y
	
	Input.set_mouse_mode(mouse_mode)

func _input(event: InputEvent):
	if not is_user_input_on: return
	if is_target_locked: return
	if not event is InputEventMouseMotion: return
	
	target_x_rotation -= event.relative.y * sensitivity * v_sensitivity / sensitivity_divider
	target_y_rotation -= event.relative.x * sensitivity * h_sensitivity / sensitivity_divider

func _process(delta: float):
	var speed := turn_rate
	
	if is_target_locked:
		if lock_object:
			lock_position = lock_object.global_position
		if lock_position:
			var direction = camera.global_position - lock_position
			var distance = Vector2(direction.x, direction.z).length()
			
			lock_angle = Vector2(
				atan2(-direction.y, distance),
				atan2(direction.x, direction.z)
			)
		
		target_x_rotation = lock_angle.x
		target_y_rotation = lock_angle.y
		speed = lock_turn_rate
	elif not is_rotating: return
	
	camera.rotation.x = lerp(camera.rotation.x, target_x_rotation, speed * delta)
	trypod.rotation.y = lerp(trypod.rotation.y, target_y_rotation, speed * delta)
	
	if is_at_target_rotation():
		is_rotating = false
		if lock_await_goal: unlock()
