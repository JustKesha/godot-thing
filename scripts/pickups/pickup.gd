class_name Pickup extends Interactable

signal picked_up(amount: int) ## Emits when quantity is reduced due to an interaction.
## If [member allow_overflow] is [code]false[/code] only emits when quantity reaches 0,
## otherwise will emit any time the quantity is reduced.
signal exhausted()

## [Pickup] ID.[br]NOTE Assigned in [method Pickups.get_by_id] according to the scene file name stored in [member Pickups.DATA].
var id := ''
## [Pickup] rarity.[br]NOTE Assigned in [method Pickups.get_by_id] according to the [member Pickups.DATA] table.
var rarity := Pickups.Rarity.ANY

@export_group("Item")
## ID of the [class Item] given to player on [method Interactable.interact].
@export var item := 'candle'
## Total quantity of the [member item] that can be obtained from this [Pickup].
@export var quantity := 1
## The maximum quantity of [member item] a player can get from a single [method Interactable.interact].
@export var pickup_rate := 99
## If set to [code]true[/code] will delete the [Pickup] after first [method Interactable.interact].
@export var allow_overflow := false

@export_group("Particles", "particles_")
@export var particles_on_spawn := true ## Whether or not should [Pickup] emit particles on spawn.
@export var particles_on_remove := true ## Whether or not should [Pickup] emit particles on remove.
@export var particles_type := particles.Particles.POOF ## The type of particles to emit.
@export var particles_scale := Vector3.ONE ## The scale of particles.
@export var particles_offset := Vector3.ZERO ## Particles offset from the [Pickup] center.

# GENERAL

func _on_interact():
	var overflow := 0
	var pickup_amount := 0
	
	if pickup_rate > quantity:
		pickup_amount = quantity
	else:
		pickup_amount = pickup_rate
		overflow += quantity - pickup_amount
	
	overflow += player.inventory.add(item, pickup_amount)
	
	if pickup_amount - overflow > 0:
		picked_up.emit(pickup_amount - overflow)
	
	if overflow == 0 or allow_overflow:
		exhausted.emit()
		remove()
	else:
		quantity = overflow

func _on_ready():
	if particles_on_spawn:
		particles.spawn(self.global_position + particles_offset,
			particles_type, null, particles_scale)

func _on_remove():
	if particles_on_remove:
		particles.spawn(self.global_position + particles_offset,
			particles_type, null, particles_scale)
