extends Node

@onready var player: PlayerAPI = $"../Game/Player/API"
@onready var world: WorldAPI = $"../Game/World/API"

# SHORTCUTS

@onready var segment: WorldSegment:
	get(): return world.generator.current_segment
