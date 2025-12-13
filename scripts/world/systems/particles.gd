class_name ParticleSystem extends Node

enum Particles {
	POOF = 0,
	SPARK = 1
	}
@export var particles: Array[PackedScene] = [
	preload("res://scenes/objects/particles/poof.tscn"),
	preload("res://scenes/objects/particles/spark.tscn")
	]

## Spawns particles by id, by default assigns them to the current world segment.     
func spawn(position: Vector3 = Vector3.ZERO, id: Particles = Particles.POOF,
	parent: Node3D = null) -> ParticlesObject:
	if id < 0 or id > len(particles):
		push_error('Tried to spawn particles by unknown id: ', id)
		return null
	if parent == null: parent = References.segment
	if parent == null:
		push_error('Both given parent and current world segment are null')
		return null
	var node: ParticlesObject = particles[id].instantiate()
	parent.add_child(node)
	node.global_position = position
	return node
