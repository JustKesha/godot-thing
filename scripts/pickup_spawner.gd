class_name PickupSpawner extends Node3D

@export var comm_chance := -1.0
@export var rare_chance := -1.0
@export var epic_chance := -1.0

func _ready():
	var pickup = Pickups.get_random(-1, comm_chance, rare_chance, epic_chance)
	if not pickup: return
	self.add_child(pickup)
