class_name PlayerHands extends RayCast3D

@export var player: PlayerAPI

var is_hovered := false
var hovered: Interactable = null:
	set(value):
		if hovered == null and is_hovered: pass
		elif hovered is Interactable and not hovered.is_enabled: pass
		elif hovered == value: return
		
		if hovered != null: hovered.unhover()
		
		if value is Interactable and value.is_enabled:
			hovered = value
			hovered.hover()
			player.cursor.state = player.cursor.States.INSPECT
			player.info_popup.set_info(hovered.info_title, hovered.info_desc)
			is_hovered = true
		else:
			hovered = null
			player.cursor.state = player.cursor.States.HIDDEN
			is_hovered = false

func _process(_delta: float):
	hovered = get_collider()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('interact'):
		if hovered: hovered.interact(player)
