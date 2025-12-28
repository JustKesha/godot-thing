class_name PickupStand extends Node3D

@onready var particles := References.particles

signal rolled(pickup: Pickup)
signal appearing() ## Appear animation started
signal appeared() ## Appear animation finished
signal disappearing() ## Disappear animation started
signal disappeared() ## Disappear animation finished

# NOTE Starting from 1 bc by default state is set to 0
enum State { APPEARING = 1, APPEARED = 2, DISAPPEARING = 3, DISAPPEARED = 4 }
var state: State:
	set(value):
		if value == state: return
		state = value
		match value:
			State.APPEARING:
				if not animation_player:
					state = State.APPEARED
					return
				animation_player.play(animation_appear)
				appearing.emit()
			State.APPEARED:
				appeared.emit()
				roll()
			State.DISAPPEARING:
				if is_instance_valid(pickup) and not pickup.is_queued_for_deletion():
					pickup.remove()
				if not animation_player:
					state = State.DISAPPEARED
					return
				animation_player.play(animation_disappear)
				disappearing.emit()
			State.DISAPPEARED:
				if is_instance_valid(pickup) and not pickup.is_queued_for_deletion():
					pickup.remove()
				queue_free()
				disappeared.emit()

@export_group("General")
@export var is_hidden: bool = false
@export var allow_multiple_interactions: bool = true
@export var pickup_spawn_point: Node3D

@export_group("Animations")
@export var animation_player: AnimationPlayer
@export var animation_appear: String = 'APPEAR'
@export var animation_disappear: String = 'DISAPPEAR'

@export_group("Particles")
@export var particles_on_roll := particles.Particles.POOF
@export var particles_scale: float = 2.5
@export var particles_offset: Vector3 = Vector3(0, .25, .25)

var pickup: Pickup:
	set(value):
		pickup = value
		pickup_spawn_point.add_child(pickup)
		pickup.position = Vector3.ZERO
		
		pickup.picked_up.connect(_on_picked_up)
		pickup.removed.connect(_on_pickup_removed)
		
		particles.spawn(pickup_spawn_point.global_position + particles_offset,
			particles_on_roll, self, Vector3.ONE * particles_scale)
			
		rolled.emit(pickup)

func roll():
	pickup = Pickups.get_truly_random()

func appear():
	state = State.APPEARING

func disappear():
	state = State.DISAPPEARING

# GENERAL

func _ready():
	if not pickup_spawn_point: pickup_spawn_point = self
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)
	if not is_hidden: appear()

func _on_animation_finished(anim_name: StringName):
	match anim_name:
		animation_appear:
			state = State.APPEARED
		animation_disappear:
			state = State.DISAPPEARED

func _on_picked_up(_amount: int):
	if not allow_multiple_interactions:
		disappear()

func _on_pickup_removed():
	disappear()
