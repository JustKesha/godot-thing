class_name Item extends Node3D

@export var id: String
@onready var player: PlayerAPI = References.player_api
var is_initiated := false

@export_group("Selection")
@export var on_selection_display: Node3D
var is_selected := true:
	set(value):
		if value == is_selected: return
		is_selected = value
		on_selection_display.visible = is_selected
		if is_selected: _on_select()
		else: _on_deselect()

@export_group("Stack")
@export var quantity := 1:
	set(value):
		quantity = value
		if quantity <= 0: destroy()
		elif quantity > stack: quantity = stack
		update_ui()
enum StackSize { NONE = 1, SMALL = 3, MEDIUM = 5, BIG = 10, HUGE = 16 }
@export var stack := StackSize.NONE

@export_group("Consumable")
@export var is_consumable := true
@export var consume_quantity := 1

@export_group("Responses")
var dialogue_window
@export var on_use_responses: Array[String] = []
@export var on_deny_responses: Array[String] = []

@export_group("UI")
@export_file("*.png") var icon_path: String
@export var inventory_slot_ui: PackedScene
@export var tag: String
var ui: ItemInventoryUI

# INFO These can be overwritten in inherited scripts
func _on_init(): pass
func _on_use() -> bool: return true
func _on_destroy() -> bool: return true
func _on_select(): pass
func _on_deselect(): pass

func init(item_name: String):
	if not id: id = item_name
	ui = inventory_slot_ui.instantiate()
	ui.set_item(self)
	_on_init()
	is_selected = true
	is_initiated = true

func use():
	if not is_initiated: return
	if not _on_use():
		if len(on_deny_responses):
			dialogue_window.display(on_deny_responses.pick_random())
		return
	if len(on_use_responses):
		dialogue_window.display(on_use_responses.pick_random())
	if is_consumable: quantity -= consume_quantity

func destroy():
	if not is_initiated: return
	if not is_instance_valid(self): return
	if not _on_destroy(): return
	delete()

func delete():
	player.inventory.remove(self)
	ui.destroy()
	queue_free()

func update_ui():
	if ui: ui.update()

func _ready():
	print(References.player_api)
	print(References.player_api.dialogue_window)
	dialogue_window = References.player_api.dialogue_window
