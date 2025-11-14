class_name WorldAPI extends Node

@export_group("General")
@export var generator: WorldGenerator
@export var moon: Node3D

func _ready() -> void: References.world_api = self
