class_name ItemInventoryUI extends VBoxContainer

@export var icon: TextureRect
@export var nametag: Label
@export var quantity: Label
@export var selection_background: Control
@export var selection_foreground: Control

var parent_item: Item

func set_icon(path: String): icon.texture = load(path)
func set_nametag(tag: String): nametag.text = tag
func set_quantity(new: int): quantity.text = 'x' + str(new)
func set_selection(selected: bool):
	selection_background.visible = selected
	selection_foreground.visible = selected

func init(item: Item):
	item.player.inventory.inventory_ui.add_child(self)
	set_icon(item.icon_path)
	parent_item = item
	update()

func update():
	set_nametag(parent_item.tag)
	set_quantity(parent_item.quantity)
	set_selection(parent_item.is_selected)

func destroy():
	self.queue_free()
