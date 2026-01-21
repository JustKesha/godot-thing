class_name WanderingSoot extends Node3D

@onready var particles := References.particles

signal moved(to: Vector3, from: Vector3)
signal died()

func _on_update(): pass
func _on_death(): pass
func _on_move(old_position: Vector3): pass

@export_group("States")
@export var is_hidden: bool = false:
	set(value):
		is_hidden = value
		if particles_alive: particles_alive.emitting = not is_hidden
@export var is_sleeping: bool = true
@export var intensity_to_wake_up: float = 0.01
@export var update_timer: Timer:
	set(value):
		update_timer = value
		update_timer.one_shot = false
		update_timer.start()
		update_timer.timeout.connect(update)

@export_group("Particles", "particles_")
@export var particles_alive: GPUParticles3D:
	set(value):
		particles_alive = value
		particles_alive.one_shot = false
		particles_alive.emitting = not is_hidden
@export var particles_death: ParticleSystem.Particles

var light_intensity = 0.0:
	set(value):
		light_intensity = value
		if is_sleeping and light_intensity >= intensity_to_wake_up:
			is_sleeping = false

func move(new_position: Vector3):
	var old_position := self.global_position
	self.global_position = new_position
	
	_on_move(old_position)
	moved.emit(new_position, old_position)

func die():
	queue_free()
	
	particles.spawn(self.global_position, particles_death)
	_on_death()
	died.emit()

func update():
	light_intensity = Util.get_light_intensity_at_point(self.global_position)
	_on_update()
