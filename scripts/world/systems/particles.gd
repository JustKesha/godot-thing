class_name ParticleSystem extends Node

@export var particles: Array[PackedScene] = [
	preload("res://scenes/objects/particles/poof.tscn"),
	preload("res://scenes/objects/particles/spark.tscn"),
	preload("res://scenes/objects/particles/dust.tscn"),
	]
enum Particles {
	POOF = 0,
	SPARK = 1,
	DUST = 2
	}

## Spawns particles by id, by default assigns them to the current world segment.     
func spawn(position: Vector3 = Vector3.ZERO, id: Particles = Particles.POOF,
	parent: Node = null, scale: Vector3 = Vector3.ONE) -> ParticlesObject:
	if id < 0 or id > len(particles):
		push_error('Tried to spawn particles by unknown id: ', id)
		return null
	if parent == null: parent = References.segment
	if parent == null:
		push_error('Both given parent and current world segment are null')
		return null
	
	var particles_node: ParticlesObject = particles[id].instantiate()
	parent.add_child(particles_node)
	particles_node.global_position = position
	particles_node.scale = scale
	return particles_node
