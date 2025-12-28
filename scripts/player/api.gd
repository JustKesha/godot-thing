class_name PlayerAPI extends Node

@export_group("General")
@export var eyes: PlayerInteractor
@export var lantern: PlayerLantern
@export var inventory: PlayerInventory
@export var camera: PlayerCameraController
@export var camera_effects: PlayerCameraEffects
@export var movement: PlayerMovementController

@export_group("Body")
@export var body: Node3D
@export var head: Node3D

@export_group("UI")
@export var cursor: PlayerCursor
@export var dialogue_window: PlayerDialogueWindow

## In locked state player:
## 1. Cant move
## 2. Lantern fuel depletion (from burning) is paused
## NOTE Read only, use lock & unlock methods instead
var is_locked: bool:
	get(): return movement.is_locked and lantern.is_fuel_depletion_paused

func lock(source: String):
	movement.lock(source)
	lantern.pause_depletion(source)

func unlock(source: String):
	movement.unlock(source)
	lantern.unpause_depletion(source)
