class_name PlayerHands extends RayCast3D

@export var player: PlayerAPI

var hovered: Interactable = null:
	set(value):
		if hovered == value: return
		if hovered != null: hovered.unhover()
		
		if value is Interactable:
			hovered = value
			hovered.hover()
		else:
			hovered = null

func _process(_delta: float):
	hovered = get_collider()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('interact'):
		if hovered: hovered.interact(player)
