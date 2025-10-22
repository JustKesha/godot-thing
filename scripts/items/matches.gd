extends Item

func use(player: PlayerAPI):
	player.lantern.reignite()
	player.inventory.remove(self)

func _ready():
	self.rotation = Vector3(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
