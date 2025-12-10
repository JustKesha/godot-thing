class_name ParticleSystem extends Node

enum Particles {
	POOF = 0
	}
@export var particles: Array[PackedScene] = [
	preload("res://scenes/objects/particles/poof.tscn")
	]

## Spawns particles by id, by default assigns them to the current world segment.      
func spawn(id: Particles = Particles.POOF, position: Vector3 = Vector3.ZERO,
	segment: WorldSegment = null) -> ParticlesObject:
	if segment == null: segment = References.segment
	if id < 0 or id > len(particles):
		push_error('Tried to spawn particles by unknown id: ', id)
		return null
	var node: ParticlesObject = particles[id].instantiate()
	segment.add_child(node)
	node.global_position = position
	return node
