class_name WorldGenerator extends Node

@export var world: Node3D
@export var player: Node3D

@export_group("Segmentation")
@export var preload_segments := 10
@export var segment_spacing := 10.0
@export var segment_unload_at_z := 20.0
var loaded_segments: Array[Node3D] = []

func init() -> void:
	clear()
	update()

func update() -> void:
	clean()
	
	while len(loaded_segments) < preload_segments:
		load_segment(get_next_segment())

func move(delta: float, speed: float = Stats.speed) -> void:
	for segment in loaded_segments:
		segment.position.z += delta * speed

func clear() -> int:
	var segments_removed := 1
	for segment in loaded_segments:
		if is_instance_valid(segment):
			segment.queue_free()
			segments_removed += 1
	loaded_segments.clear()
	return segments_removed

func clean() -> int:
	var segments_to_remove: Array[Node3D] = []
	
	for segment in loaded_segments:
		if is_segment_unload_time(segment):
			segments_to_remove.append(segment)
	
	for segment in segments_to_remove:
		unload_segment(segment)
	
	return len(segments_to_remove)

func load_segment(segment: Resource) -> void:
	var instance := segment.instantiate() as Node3D
	world.add_child(instance)
	instance.global_position = get_next_segment_position()
	loaded_segments.append(instance)

func unload_segment(segment: Node3D) -> void:
	if is_instance_valid(segment):
		segment.queue_free()
		loaded_segments.erase(segment)

func get_next_segment_position() -> Vector3:
	var index = len(loaded_segments) - 1
	var pos = Vector3.FORWARD * index * segment_spacing
	
	return pos

func get_next_segment() -> Resource:
	return SetPieces.pieces.pick_random()

func is_segment_unload_time(segment: Node3D) -> bool:
	return segment.position.z > segment_unload_at_z

func _on_player_move() -> void:
	update()

func _ready() -> void:
	init()
