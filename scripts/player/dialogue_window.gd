class_name PlayerDialogueWindow extends CanvasItem

@export var label: Label
@export var timer: Timer

var is_active := false:
	set(value):
		is_active = value
		self.visible = is_active
		if not is_active:
			is_typing = false
var message := "":
	set(value):
		message = value
		label.text = value
		is_active = len(message) > 0

@export_group("General")
@export var default_message := "..."
@export var default_timeout := 3.5

@export_group("Typing")
enum TypeDelay {
	NONE = 0,
	EXTRA_DRAMATIC = 3000, DRAMATIC = 1000, SLOW = 500,
	NORMAL = 200,
	FAST = 150, FASTEST = 75
	}
@export var default_type_delay := TypeDelay.FAST
var _type_delay_multiplier := 0.0001
@export var type_slow_characters := {
	".": TypeDelay.EXTRA_DRAMATIC,
	"!": TypeDelay.EXTRA_DRAMATIC,
	"?": TypeDelay.EXTRA_DRAMATIC,
	",": TypeDelay.DRAMATIC,
	"-": TypeDelay.DRAMATIC,
	":": TypeDelay.DRAMATIC,
	";": TypeDelay.DRAMATIC,
}
var is_typing := false
var _type_message := "":
	set(value):
		_type_message = value
		is_typing = len(_type_message) > 0
		is_active = is_typing
var _type_delay := 0.0
var _type_timer := 0.0
var _type_timeout := 0.0

func display(text: String = default_message, delay: float = default_type_delay,
	timeout: float = default_timeout):
	stop_timeout()
	if delay > 0:
		_type_message = text
		_type_delay = delay * _type_delay_multiplier
		_type_timeout = timeout
	else:
		message = text
		start_timeout(timeout)

func type(delta: float):
	if not is_typing: return
	if _type_timer > 0:
		_type_timer -= delta
		return
	
	var new_char := _type_message[len(message)]
	message += new_char
	
	if len(message) == len(_type_message):
		is_typing = false
		start_timeout(_type_timeout)
		return
	
	if type_slow_characters.keys().has(new_char):
		_type_timer = type_slow_characters[new_char] * _type_delay_multiplier
	else:
		_type_timer = _type_delay

func start_timeout(timeout: float = default_timeout):
	if timeout > 0: timer.start(timeout)

func stop_timeout():
	timer.stop()
	message = ""

func _process(delta: float):
	if not is_active: return
	type(delta)

func _on_timer_timeout():
	stop_timeout()

func _unhandled_input(event: InputEvent):
	if is_active and event.is_action_pressed('skip'):
		if is_typing:
			display(_type_message, 0)
		else:
			stop_timeout()
