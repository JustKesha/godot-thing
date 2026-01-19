class_name PickupSpawner extends Node3D

@onready var particles := References.particles

signal appearing()
signal appeared()
signal pickup_changed(pickup: Pickup)
signal disappearing()
signal disappeared()
signal removed()

enum State { APPEARING = 1, APPEARED, DISAPPEARING, DISAPPEARED }
var state: State:
	set(value):
		if value == state: return
		state = value
		match state:
			State.APPEARING:
				if not _set_animation(animation_appear): state = State.APPEARED
				appearing.emit()
			State.DISAPPEARING:
				clear()
				if not _set_animation(animation_disappear): state = State.DISAPPEARED
				disappearing.emit()
		match state:
			State.APPEARED:
				_set_animation(animation_idle)
				appeared.emit()
				roll()
			State.DISAPPEARED:
				clear()
				remove()
				disappeared.emit()

@export_group("General")
@export var is_hidden: bool = false
@export var allow_multiple_interactions: bool = true
@export var spawn_point: Node3D = self

@export_group("Loot", "loot_")
@export var loot_pool: Pickups.Pool = Pickups.Pool.ALL
@export var loot_chances: Pickups.Chances = Pickups.Chances.OKAY

@export_group("Animation", "animation_")
@export var animation_enabled: bool = false
@export var animation_player: AnimationPlayer
@export var animation_idle: String = 'IDLE'
@export var animation_appear: String = 'APPEAR'
@export var animation_disappear: String = 'DISAPPEAR'

@export_group("Particles", "particles_")
@export var particles_enabled: bool = false

var pickup: Pickup:
	set(value):
		if is_instance_valid(pickup) and not pickup.is_queued_for_deletion():
			pickup.remove()
		
		pickup = value
		
		if pickup:
			pickup.particles_on_spawn = particles_enabled
			spawn_point.add_child(pickup)
			pickup.position = Vector3.ZERO
			pickup.picked_up.connect(_on_picked_up)
			pickup.removed.connect(_on_pickup_removed)
		
		pickup_changed.emit(pickup)

# ACTIONS

func roll():
	pickup = Pickups.get_by_roll(loot_pool, loot_chances)

func clear():
	pickup = null

func appear():
	state = State.APPEARING

func disappear():
	state = State.DISAPPEARING

func remove():
	queue_free()
	removed.emit()

# HELPERS

## Plays given animation on player, returns true if animation started.
func _set_animation(name: String) -> bool:
	if( not animation_enabled or not animation_player
		or not animation_player.has_animation(name) ): 
		return false
	animation_player.play(name)
	return true

# GENERAL

func _ready():
	if animation_player: animation_player.animation_finished.connect(_on_animation_finished)
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
