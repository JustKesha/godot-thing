class_name Item extends Node3D

var is_initiated := false
var player: PlayerAPI
var id: String

@export_group("Stack")
@export var quantity := 1:
	set(value):
		quantity = value
		
		if quantity <= 0:
			destroy()
		
		elif quantity > stack:
			quantity = stack
@export var stack := 1

# These should be rewritten in inherited scripts
func _init(): pass
func _use(): pass
func _destroy(): pass

func init(item_id: String, player_api: PlayerAPI):
	id = item_id
	player = player_api
	_init()
	is_initiated = true

func use():
	if not is_initiated: return
	_use()
	quantity -= 1

func destroy():
	if not is_initiated: return
	_destroy()
	player.inventory.remove(self)
