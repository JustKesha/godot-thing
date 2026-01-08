class_name Observer extends Node
## Can track [Node3D] type objects with [member head] & [member eyes], as well as
## change [member pupil_size].

@export_group("Body")

@export_subgroup("Head")
@export var head: Node3D ## [Observer]'s head.
@export var head_turn_rate: float = 1.0 ## [member head]'s turn rate.

@export_subgroup("Eyes")
@export var eyes: Array[Eye] = [] ## [Observer]'s eyes.
## Sets [member Eye.turn_rate] for each of [Observer]'s [member eyes].
@export var eyes_turn_rate: float = 1.0:
	set(value):
		eyes_turn_rate = value
		for eye in eyes:
			if not eye: continue
			eye.turn_rate = eyes_turn_rate
enum PupilSize { RELAXED = 130, NORMAL = 75, ALERT = 50, HAUNT = 0 }
## Sets [member Eye.pupil_size] for each of [Observer]'s [member eyes].
@export var pupil_size: PupilSize = PupilSize.NORMAL:
	set(value):
		pupil_size = value
		for eye in eyes:
			if not eye: continue
			eye.set_pupil_size(float(pupil_size))

@export_group("Tracking")
## The object that [Observer]'s [member head] and [member eyes] are currently tracking.
## [br][br]NOTE: [member head] is turned using [method _turn] but [member eyes]
## logic is covered in a separate script.
@export var target_object: Node3D:
	set(value):
		target_object = value
		for eye in eyes:
			if not eye: continue
			eye.follow(target_object)

## Start tracking a [Node3D] and set it as [member target_object].
func track(object: Node3D):
	target_object = object

## Stop tracking the [member target_object].
func stop_tracking():
	target_object = null

## Slowly turns the [member head] to face [member target_object].
func _turn(delta: float = -1):
	if not head or not target_object: return
	if delta < 0: delta = get_process_delta_time()
	Util.turn(head, target_object.global_position, head_turn_rate * delta)

func _physics_process(delta: float):
	_turn(delta)
