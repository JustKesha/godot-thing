class_name PlayerInventory extends Node3D

signal opened()
signal closed()
signal item_added(item: Item, quantity: int)
signal item_removed(item: Item)
signal item_selected(item: Item)
signal item_unselected(item: Item)

@onready var player: PlayerAPI = References.player
var debug_info: String:
	get():
		if not items: return ''
		var str := 'INV: '
		for i in range(len(items)):
			var item = items[i]
			if i != 0: str += ',\n     '
			str += item.id.to_upper()+' x'+str(item.quantity)+'/'+str(item.stack)
		return str

@export_group("General")
@export var slots := 4
@export var inventory_full_responses: Array[String] = [
	'',
	]
var is_open := false:
	set(value):
		if value == is_open: return
		is_open = value
		
		if is_open:
			_show_item()
			Logger.write(debug_info)
			opened.emit()
		else:
			_hide_item()
			closed.emit()
var items: Array[Item] = []
var active_slot := 0:
	set(value):
		_hide_item()
		active_slot = clamp(value, 0, len(items)-1)
		_show_item()
		is_open = true

@export_group("Controls")
@export var open_action := 'inventory'
@export var use_action := 'use'
@export var select_slot_action_prefix := 'inventory_slot_'

@export_group("Responses")
@export var responses_acquired: Array[String] = ['+']
@export var responses_brimfull: Array[String] = ['Full.']
@export var responses_overflow: Array[String] = ['Full.']

@export_group("UI")
@export var ui: HBoxContainer

@export_group("Other")
@export var starting_items: Array[String] = []

# TODO Simplify
func add(item_id: String, quantity: int = 1) -> int:
	var item
	var item_in_inv := find_item(item_id)
	
	var quantity_overflow := 0
	var quantity_before := 0
	var quantity_added := 0
	
	if item_in_inv and item_in_inv.stack > 1:
		item = item_in_inv
		
		quantity_before = item.quantity
		item.quantity += quantity
		active_slot = get_item_slot(item_id)
	else:
		if len(items) == slots:
			player.dialogue_window.display(responses_brimfull.pick_random())
			return quantity
		item = Items.get_by_id(item_id)
		if not item: return -1
		
		item.init(item_id)
		items.append(item)
		self.add_child(item)
		
		item.quantity = quantity
		active_slot = len(items) - 1
	
	quantity_overflow = quantity_before + quantity - item.quantity
	quantity_added = quantity - quantity_overflow
	
	if quantity_added > 0:
		player.dialogue_window.display(
			responses_acquired.pick_random() + " "
			+ str(quantity_added) + " " + item_id + ".")
		Logger.write(debug_info)
		open()
		item_added.emit(item, quantity_added)
	elif quantity == quantity_overflow:
		player.dialogue_window.display(responses_overflow.pick_random())
	
	return quantity_overflow

func use(slot: int = active_slot) -> bool:
	var item = get_item(slot)
	if not item: return false
	item.use()
	return true

func remove(item: Item) -> bool:
	for i in items:
		if i == item:
			items.erase(item)
			item.destroy()
			active_slot = active_slot
			Logger.write(debug_info)
			if not items: close()
			item_removed.emit(item)
			return true
	return false

func init():
	clear()
	give_starting_items()
	close()

func open():
	is_open = true

func close():
	is_open = false

func clear():
	for item in items:
		remove(item)

func give_starting_items(list: Array[String] = starting_items):
	for item_id in starting_items: add(item_id)

func _show_item(item: Item = null):
	if not item: item = get_active()
	if not item: return
	item.is_selected = true
	item.update_ui()
	item_selected.emit(item)

func _hide_item(item: Item = null):
	if not item: item = get_active()
	if not item: return
	item.is_selected = false
	item.update_ui()
	item_unselected.emit(item)

# HELPERS

## Returns the item for given slot or null.
func get_item(slot: int) -> Item:
	if slot < 0 or slot >= len(items): return null
	return items[slot]

## Returns slot index if item is in inventory, otherwise -1.
func get_item_slot(item_id: String) -> int:
	for i in range(len(items)):
		if items[i].id == item_id:
			return i
	return -1

## Returns the currently selected item, or the last selected item if inventory is
## is closed. If inventory is empty (or no item was ever selected) will return null.
func get_active() -> Item:
	return get_item(active_slot)

## Get item from inventory by id, otherwise get null.
func find_item(id: String) -> Item:
	for item in items:
		if item.id == id:
			return item
	return null

# GENERAL

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(open_action):
		if is_open: close()
		else: open()
		return
	
	if is_open:
		if event.is_action_pressed(use_action):
			use()
			return
	
	for slot in range(len(items)):
		if not event.is_action_pressed(select_slot_action_prefix + str(slot+1)):
			continue
		
		if slot == active_slot:
			if is_open: close()
			else: open()
			return
		
		active_slot = slot
		return

func _ready():
	init()
