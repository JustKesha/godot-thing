class_name WorldGenerator extends Node

@export var world: Node3D

@export_group("Segmentation")
@export var preload_segments := 10
@export var segment_spacing := 10.0
@export var segment_unload_at_z := 20.0
var loaded_segments: Array[Node3D] = []
var current_segment: WorldSegment

@export_group("Horizon")
@export var horizon_start_at_segment := 1
@export var horizon_depth := .1

## Clears the map and loads up a new one.
func init():
	clear()
	update()

## Loads new segments and unloads old ones when needed.
func update():
	clean()
	while len(loaded_segments) < preload_segments:
		load_segment(get_next_segment_to_load())

## Removes all loaded segments.
func clear() -> int:
	var segments_removed := 0
	for segment in loaded_segments:
		if is_instance_valid(segment):
			segment.queue_free()
			segments_removed += 1
	loaded_segments.clear()
	return segments_removed

## Unloades all passed segments.
func clean() -> int:
	var segments_to_remove: Array[Node3D] = []
	
	for segment in loaded_segments:
		if is_segment_unload_time(segment):
			segments_to_remove.append(segment)
	
	for segment in segments_to_remove:
		unload_segment(segment)
	
	return len(segments_to_remove)

## Moves all segments along the z axis.
func move(by: float):
	for segment in loaded_segments:
		segment.position.z += by
		if segment.position.y < 0:
			segment.position.y = clamp(
				segment.position.y + by * horizon_depth, -INF, 0)
	update()
	current_segment = get_current_segment()

# ACTIONS

func load_segment(segment: WorldSegment):
	if not segment is WorldSegment:
		push_error("Trying to load a null segment.")
		return
	world.add_child(segment)
	segment.position = get_next_segment_position()
	loaded_segments.append(segment)

func unload_segment(segment: WorldSegment):
	if is_instance_valid(segment):
		segment.queue_free()
		loaded_segments.erase(segment)

# HELPERS

func get_next_segment_position() -> Vector3:
	var index = get_next_segment_index()
	var pos = Vector3.FORWARD * index * segment_spacing
	if index >= horizon_start_at_segment:
		pos.y = ((index - horizon_start_at_segment) * segment_spacing
			* -horizon_depth)
	return pos

func get_next_segment_index() -> int:
	return len(loaded_segments) - 1

func get_next_segment_to_load() -> WorldSegment:
	return WorldSegments.roll()

func is_segment_unload_time(segment: WorldSegment = loaded_segments[0]) -> bool:
	return segment.position.z > segment_unload_at_z

func get_current_segment() -> WorldSegment:
	var player_z := References.player.body.global_position.z
	for segment in loaded_segments:
		if( segment.position.z + segment_spacing/2 > player_z
			and segment.position.z - segment_spacing/2 < player_z ):
			return segment
	return null

# GENERAL

func _ready():
	init()

func _on_player_move(step: float):
	move(step)
