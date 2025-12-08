class_name PlayerInteractionTooltip extends Control

@export var action: Label
@export var title: Label
@export var desc: Label
@export var key: Label

func set_action(text: String): action.text = text
func set_title(text: String): title.text = text
func set_desc(text: String): desc.text = text
func set_key(text: String): key.text = 'Press ' + text + ' to'

func set_info(title_text: String, desc_text: String, action_text: String,
	key_text: String):
	set_action(action_text)
	set_title(title_text)
	set_desc(desc_text)
	set_key(key_text)
