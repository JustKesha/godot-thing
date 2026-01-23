class_name PlayerInteractor extends RayCast3D

@onready var particles: ParticleSystem = References.particles

var collider: Object
var is_hovered := false
var hovered: Interactable:
	set(value):
		if hovered == null and is_hovered: pass
		elif hovered is Interactable and not hovered.is_enabled: pass
		elif hovered == value: return
		
		if hovered != null: hovered.unhover()
		
		if value is Interactable and value.is_enabled:
			hovered = value
			hovered.hover()
			is_hovered = true
		else:
			hovered = null
			is_hovered = false

func _process(_delta: float):
	collider = get_collider()
	hovered = collider if collider is Interactable else null

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('interact'):
		if hovered:
			hovered.interact()
		elif collider:
			particles.spawn(get_collision_point(), particles.Particles.DUST)
