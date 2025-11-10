class_name InteractableDiceRoll extends Interactable

@export var dice: Dice

func _on_interact(_player: PlayerAPI):
	dice.roll()
