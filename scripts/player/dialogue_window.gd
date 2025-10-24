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

func display(text: String = "...", timeout: float = 2.5):
	is_active = true
	
	message = text
	
	if timeout > 0:
		timer.stop()
		timer.start(timeout)

func _on_timer_timeout():
	is_active = false
