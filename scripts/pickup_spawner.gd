class_name PickupSpawner extends Node3D

@export_group("Simplified")
@export var use_simplified := true
@export var pool := Pickups.PickupPool.ALL
@export var chances := Pickups.Chances.OKAY

@export_group("Full")
@export var comm_chance := -1.0
@export var rare_chance := -1.0
@export var epic_chance := -1.0
@export var comm_pool: Array[Resource] = []
@export var rare_pool: Array[Resource] = []
@export var epic_pool: Array[Resource] = []

func _ready():
	var pickup
	if use_simplified:
		pickup = Pickups.get_random(pool, chances, -1)
	else:
		pickup = Pickups._get_random(-1, comm_chance, rare_chance, epic_chance, 
			epic_pool, rare_pool, comm_pool)
	
	if not pickup: return
	self.add_child(pickup)
