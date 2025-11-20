class_name PlayerAPI extends Node

@export_group("General")
@export var body: Node3D
@export var lantern: PlayerLantern
@export var inventory: PlayerInventory
@export var camera: PlayerCameraController
@export var camera_effects: PlayerCameraEffects

@export_group("UI")
@export var dialogue_window: PlayerDialogueWindow
@export var cursor: PlayerCursor
@export var info_popup: PlayerInfoPopup
