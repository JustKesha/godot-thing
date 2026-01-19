class_name PickupSelectionObserverAI extends ObserverAI

@export var selection: PickupSelection
@export var body: Node3D

func _ready():
	scan_enabled = false
	if selection:
		selection.disappearing.connect(_on_selection_disappearing)
		selection.appearing.connect(_on_selection_appearing)

func _on_selection_disappearing():
	scan_enabled = false
	target_object = body

func _on_selection_appearing():
	scan_enabled = true
