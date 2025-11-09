class_name Interactable extends StaticBody3D

var info_title: String:
	get(): return info_title if info_title else get_info_title()
var info_desc: String:
	get(): return info_desc if info_desc else get_info_desc()

@export var info_titles: Array[String] = ['']
@export var info_descs: Array[String] = ['']

func hover(): pass
func get_info_title() -> String:
	if not info_titles: return ''
	return info_titles.pick_random()
func get_info_desc() -> String:
	if not info_descs: return ''
	return info_descs.pick_random()
func unhover(): pass

func interact(_player: PlayerAPI): pass

func _interactable_ready(): pass
func _ready(): _interactable_ready()
func remove(): queue_free()
