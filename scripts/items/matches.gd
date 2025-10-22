extends Item

func _use():
	player.lantern.reignite()

func _ready():
	self.rotation = Vector3(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
