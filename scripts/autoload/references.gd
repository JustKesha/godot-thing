extends Node

@onready var player: PlayerAPI = $"../Game/Player/API"
@onready var world: WorldAPI = $"../Game/World/API"
@onready var particles: ParticleSystem = world.particles

# SHORTCUTS

@onready var segment: WorldSegment:
	get(): return world.generator.current_segment
