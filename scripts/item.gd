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
var ui: VBoxContainer

@export_group("Stack")
@export var quantity := 1:
	set(value):
		quantity = value
		
		if quantity <= 0:
			destroy()
		
		elif quantity > stack:
			quantity = stack
		
		update_ui()
enum StackSize { NONE = 1, SMALL = 3, MEDIUM = 5, BIG = 10, HUGE = 16 }
@export var stack := StackSize.NONE

@export_group("Consumable")
@export var is_consumable := true
@export var consume_quantity := 1

@export_group("UI")
@export_file("*.png") var texture: String

# These should be rewritten in inherited scripts
func _init(): pass
func _use() -> bool: return true
func _destroy(): pass
func _select(): pass
func _deselect(): pass

func init(item_id: String, player_api: PlayerAPI, slot_ui: VBoxContainer):
	id = item_id
	player = player_api
	ui = slot_ui
	
	var ui_texture_rect := ui.get_node("Icon") as TextureRect
	ui_texture_rect.texture = load(texture)
	update_ui()
	
	_init()
	is_initiated = true
	is_selected = true

func use():
	if not is_initiated: return
	if not _use(): return
	if is_consumable: quantity -= consume_quantity

func destroy():
	if not is_initiated: return
	_destroy()
	player.inventory.remove(self)
	
	ui.queue_free()

func update_ui():
	if not ui: return
	
	var ui_text_label := ui.get_node("Label") as Label
	
	ui_text_label.text = "x" + str(quantity)
