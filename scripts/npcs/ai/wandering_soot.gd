class_name WanderingSootAI extends WanderingSoot

@onready var player := References.player

@export_group("Movement & Navigation")
@export var speed: float = 15.0
@export var target: Node3D
@export var target_player: bool = true

@export_group("Light Sensitivity", "intensity_")
@export var intensity_uncomfortable: float = 0.06
@export var intensity_unbearable: float = 0.09
@export var intensity_deadly: float = 0.12

# ACTIONS

func update_target() -> Node3D:
	if not target and target_player:
		target = player.body
	return target

# HELPERS

func get_target_direction() -> Vector3:
	if not target: return Vector3.ZERO
	return (target.global_position - self.global_position).normalized()

func get_direction_offset() -> Vector3:
	return Vector3(1,0,1) * randf_range(-1, 1)

# GENERAL

func _on_update():
	if is_sleeping: return
	if not is_hidden and light_intensity >= intensity_deadly: return die()
	
	var direction := get_target_direction()
	var offset := get_direction_offset()
	var delta := get_process_delta_time()
	
	is_hidden = light_intensity >= intensity_unbearable
	if light_intensity >= intensity_uncomfortable: direction *= -1
	
	move(self.global_position + (direction + offset) * speed * delta)

func _ready():
	update_target()
