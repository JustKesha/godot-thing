class_name Item extends Node3D

var is_initiated := false
var is_selected := true:
	set(value):
		if value == is_selected: return
		
		is_selected = value
		
		$Display.visible = is_selected
		if is_selected: _select()
		else: _deselect()
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

@export_group("Consumable")
@export var is_consumable := true
@export var consume_quantity := 1

# These should be rewritten in inherited scripts
func _init(): pass
func _use(): pass
func _destroy(): pass
func _select(): pass
func _deselect(): pass

func init(item_id: String, player_api: PlayerAPI):
	id = item_id
	player = player_api
	_init()
	is_initiated = true
	is_selected = true

func use():
	if not is_initiated: return
	_use()
	if is_consumable: quantity -= consume_quantity

func destroy():
	if not is_initiated: return
	_destroy()
	player.inventory.remove(self)
