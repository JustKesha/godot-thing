class_name PlayerDialogueWindow extends CanvasItem

@export var label: Label
@export var timer: Timer

var is_active := false:
	set(value):
		is_active = value
		self.visible = is_active
var message := "":
	set(value):
		message = value
		label.text = value
		is_active = len(message) > 0

func display(text: String = "...", timeout: float = 2.5):
	message = text
	if timeout > 0: timer.start(timeout)

func _on_timer_timeout():
	message = ""
