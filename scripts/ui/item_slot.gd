class_name ItemInventoryUI extends VBoxContainer

@export var icon: TextureRect
@export var nametag: Label
@export var quantity: Label
@export var selection_background: Control
@export var selection_foreground: Control
@export var min_stack_to_display: int = 1

var parent_item: Item
var is_selected: bool = false

func set_icon(path: String): icon.texture = load(path)
func set_nametag(tag: String): nametag.text = tag
func set_quantity(new: int, max: int = min_stack_to_display):
	var str = 'x' + str(new)
	if max > min_stack_to_display and is_selected:
		str += '/' + str(max)
	quantity.text = str
func set_selection(selected: bool):
	is_selected = selected
	selection_background.visible = selected
	selection_foreground.visible = selected

func set_item(item: Item):
	parent_item = item
	References.player_api.inventory.ui.add_child(self)
	set_icon(parent_item.icon_path)
	update()

func update():
	set_selection(parent_item.is_selected) # NOTE Should be called first
	set_nametag(parent_item.tag)
	set_quantity(parent_item.quantity, parent_item.stack)

func destroy():
	self.queue_free()
