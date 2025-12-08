class_name WorldGenerator extends Node

@export var world: Node3D

@export_group("Segmentation")
@export var preload_segments := 10
@export var segments_spacing := 10.0
@export var segments_behind := 2
var loaded_segments: Array[WorldSegment] = []
var current_segment: WorldSegment

@export_group("Horizon")
@export var horizon_enabled := true
@export var horizon_start_at_segment := 3
@export var horizon_depth := .1

## Clears the map and loads up a new one.
func init():
	clear()
	update()

## Loads new segments and unloads passed ones.
func update():
	clean()
	while len(loaded_segments) < preload_segments:
		load_segment()
	current_segment = get_current_segment()

## Moves all segments along the z axis.
func move(by: float):
	for segment in loaded_segments:
		segment.position.z += by
		if segment.position.y < 0:
			segment.position.y = clamp(
				segment.position.y + by * horizon_depth, -INF, 0)
	update()

## Unloades all passed segments, returns the number of unloaded segments.
func clean() -> int:
	var segments_to_unload: Array[Node3D] = []
	
	# TODO OPTIMIZE: Segments should always be loaded by load_segment()
	# -> thfor 
	for segment in loaded_segments:
		if is_segment_unload_time(segment):
			segments_to_unload.append(segment)
	
	for segment in segments_to_unload:
		unload_segment(segment)
	
	return len(segments_to_unload)

## Unloads all loaded segments.
func clear() -> int:
	var segments_removed := 0
	for segment in loaded_segments:
		if is_instance_valid(segment):
			segment.queue_free()
			segments_removed += 1
	loaded_segments.clear()
	return segments_removed

# ACTIONS

## Loads a segment into the world, if given null will use get_next_segment_to_load.
func load_segment(segment: WorldSegment = null):
	while segment == null:
		segment = get_next_segment_to_load()
	world.add_child(segment)
	segment.position = get_next_segment_position()
	loaded_segments.append(segment)

## Unloads given segment, if given null will unload the oldest segment.
func unload_segment(segment: WorldSegment = null):
	if segment == null:
		segment = loaded_segments[0]
	if is_instance_valid(segment):
		segment.queue_free()
		loaded_segments.erase(segment)

# HELPERS

func get_next_segment_position() -> Vector3:
	var last_z = (
		loaded_segments[-1].position.z if loaded_segments
		else (segments_behind + 1) * segments_spacing )
	var pos = Vector3(0, 0, last_z - segments_spacing)

	if horizon_enabled and len(loaded_segments) >= horizon_start_at_segment:
		pos.y = ( (len(loaded_segments) - horizon_start_at_segment)
			* segments_spacing * -horizon_depth )
	
	return pos

func get_next_segment_to_load() -> WorldSegment:
	return WorldSegments.roll()

func is_segment_unload_time(segment: WorldSegment) -> bool:
	return segment.position.z > (segments_behind + 1) * segments_spacing

func get_current_segment() -> WorldSegment:
	if len(loaded_segments) >= segments_behind:
		return loaded_segments[segments_behind]
	
	# NOTE Fallback manual check, should never happen
	var player_z := References.player.body.global_position.z
	
	for segment in loaded_segments:
		if( segment.position.z + segments_spacing/2 >= player_z
			and segment.position.z - segments_spacing/2 < player_z ):
			return segment
	
	return null

# GENERAL

func _ready():
	init()

func _on_player_move(step: float):
	move(step)
