class_name PlayerInfoPopup extends Control

@export var title: Label
@export var desc: Label

func set_title(text: String):
	title.text = text

func set_desc(text: String):
	desc.text = text

func set_info(title_text: String, desc_text: String):
	set_title(title_text)
	set_desc(desc_text)
