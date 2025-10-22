class_name PlayerInventory extends Node3D

@export var player: PlayerAPI
@export var slots := 3
var items: Array[Item] = []
var active_slot := 0:
	set(value):
		hide_item()
		active_slot = clamp(value, 0, len(items)-1)
		show_item()
var slot_input_prefix := 'inventory_slot_'

func add(item_name: String, quantity: int = 1) -> Item:
	# TODO Item currently dont stack (make use of quantity)
	var item = Items.get_by_name(item_name)
	
	if not item: return null
	
	items.append(item)
	self.add_child(item)
	item.visible = false
	
	active_slot += 1
	
	return item

func use(slot: int = active_slot) -> bool:
	var item = get_active()
	if not item: return false
	item.use(player)
	return true

func remove(item: Item) -> bool:
	for i in items:
		if i == item:
			items.erase(item)
			item.queue_free()
			update()
			return true
	return false

func show_item(item: Item = null):
	if not item: item = get_active()
	if not item: return
	item.visible = true

func hide_item(item: Item = null):
	if not item: item = get_active()
	if not item: return
	item.visible = false

func get_item(slot: int) -> Item:
	if not items or slot >= len(items): return null
	return items[slot]

func get_active() -> Item:
	return get_item(active_slot)

func update():
	active_slot = active_slot

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('use'):
		use()
		return
	
	for i in range(slots):
		if event.is_action_pressed(slot_input_prefix + str(i+1)):
			active_slot = i
			break
