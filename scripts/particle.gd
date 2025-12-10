class_name ParticlesObject extends GPUParticles3D

func delete():
	self.queue_free()

func _on_finished():
	if self.one_shot: delete()

func _ready():
	self.emitting = true
