class_name PlayerEffectsManager extends Node3D

@export var effects_parent: Node3D = self

@export_group("Default", "default_")
@export var default_duration: float = -1.0
@export var default_stack: int = 1
@export var default_apply_mode := Effect.DurationApplyMode.AUTO

@export_group("Starting Effects", "starting_")
@export var starting_effects: Array[StringName] = []
@export var starting_durations: Array[float] = []
@export var starting_stacks: Array[int] = []
@export var starting_apply_modes: Array[Effect.DurationApplyMode] = []

var applied_effects: Dictionary[StringName, Effect] = {}

# HELPERS

## Same as [method get_effect] but makes sure to check if the effect is active.
func is_affected(effect_id: StringName) -> Effect:
	var effect := get_effect(effect_id)
	
	if not effect or not effect.is_active:
		return null
	
	return effect

func get_effect(effect_id: StringName) -> Effect:
	if not applied_effects.has(effect_id):
		return null
	return applied_effects[effect_id]

func add_new_effect(effect_id: StringName) -> Effect:
	var effect = Effects.get_by_id(effect_id)
	
	if not effect: return null
	
	effect.apply_on_ready = false
	effects_parent.add_child(effect)
	effect.position = Vector3.ZERO
	
	register_effect(effect_id, effect)
	
	return effect

func register_effect(effect_id: StringName, effect: Effect):
	applied_effects[effect_id] = effect
	effect.removed.connect(_on_effect_self_removed)

func unregister_effect(effect_id: StringName) -> Effect:
	var effect := get_effect(effect_id)
	
	if not effect: return null
	
	applied_effects.erase(effect_id)
	
	return effect

# ACTIONS

func apply(effect_id: StringName, duration: float = default_duration,
	stack: int = default_stack, duration_apply_mode := default_apply_mode) -> Effect:
	var effect := get_effect(effect_id)               # 1. Effect already exists
	if not effect: effect = add_new_effect(effect_id) # 2. If not - Create a new one
	if not effect: return null                        # 3. Otherwise - Bad ID
	
	effect.apply(duration, stack, duration_apply_mode)
	Logger.write(debug_info)
	
	return effect

func remove(effect_id: StringName) -> int:
	var effect := unregister_effect(effect_id)
	var stacks_removed := effect.stack
	
	effect.remove()
	Logger.write(debug_info)
	
	return stacks_removed

# GENERAL

func _ready():
	for i in range(len(starting_effects)):
		var effect_id = starting_effects[i]
		var duration = starting_durations[i] if i < len(starting_durations) else default_duration
		var stack = starting_stacks[i] if i < len(starting_stacks) else default_stack
		var mode = starting_apply_modes[i] if i < len(starting_apply_modes) else default_apply_mode
		
		apply(effect_id, duration, stack, mode)

func _on_effect_self_removed(effect_id: String):
	remove(effect_id)

var debug_on: bool = true
var debug_info: String:
	get():
		if not debug_on: return ''
		
		var str := 'EFFECTS: '
		
		if not len(applied_effects): return str + 'NONE.'
		
		var i = 0
		for effect_id in applied_effects:
			var effect = applied_effects[effect_id]
			
			if not effect: continue
			
			if i != 0: str += ',\n         '
			str += (
				effect.effect_id.to_upper() + ' x'+str(effect.stack)+'/'+str(effect.stack_max)
				+' '+str(snapped(effect.get_time_left(), 0.01))+' s.'
				)
			i += 1
		return str
