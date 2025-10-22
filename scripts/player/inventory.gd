class_name PlayerInventory extends Node3D

@export var player: PlayerAPI
@export var slots := 3
var is_open := false:
	set(value):
		if value == is_open: return
		is_open = value
		
		if is_open:
			_show_item()
		else:
			_hide_item()
var items: Array[Item] = []
var active_slot := 0:
	set(value):
		if value == active_slot: return
		_hide_item()
		active_slot = clamp(value, 0, len(items)-1)
		_show_item()
		is_open = true
var slot_input_prefix := 'inventory_slot_'

func add(item_id: String, quantity: int = 1) -> Item:
	if len(items) == slots: return null
	
	var item_in_inv = find_item(item_id)
	if item_in_inv:
		item_in_inv.quantity += quantity
		open()
		logme()
		return item_in_inv
	
	var new_item = Items.get_by_id(item_id)
	if not new_item: return null
	
	new_item.init(item_id, player)
	new_item.quantity = quantity
	items.append(new_item)
	self.add_child(new_item)
	
	open()
	active_slot += 1
	
	logme()
	return new_item

func use(slot: int = active_slot) -> bool:
	var item = get_active()
	if not item: return false
	item.use()
	logme()
	return true

func remove(item: Item) -> bool:
	for i in items:
		if i == item:
			items.erase(item)
			item.queue_free()
			active_slot = active_slot
			logme()
			return true
	return false

func close():
	is_open = false

func open():
	is_open = true

func _show_item(item: Item = null):
	if not item: item = get_active()
	if not item: return
	item.is_selected = true

func _hide_item(item: Item = null):
	if not item: item = get_active()
	if not item: return
	item.is_selected = false

func get_item(slot: int) -> Item:
	if not items or slot >= len(items): return null
	return items[slot]

func get_active() -> Item:
	return get_item(active_slot)

func find_item(id: String) -> Item:
	for item in items:
		if item.id == id:
			return item
	return null

func logme():
	if not items: return
	var str := 'INV: '
	for i in range(len(items)):
		var item = items[i]
		if i != 0: str += ',\n     '
		str += item.id.to_upper()+' x'+str(item.quantity)+'/'+str(item.stack)
	print(str)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('inventory'):
		is_open = not is_open
		return
	
	if is_open:
		if event.is_action_pressed('use'):
			use()
			return
	
	for i in range(len(items)):
		if event.is_action_pressed(slot_input_prefix + str(i+1)):
			if i == active_slot:
				is_open = not is_open
				return
			
			active_slot = i
			return
