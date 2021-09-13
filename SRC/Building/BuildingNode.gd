class_name BuildingNode
extends Sprite

var data: Building setget _set_building
var destroy := -1
var active := true setget _set_active

func _ready() -> void:
	data = load("res://Assets/Buildings/Empty.tres")


func _set_building(_data: Building) -> void:
	self.active = true
	data = _data
	if "destroy" in data.build_stats:
		destroy = data.build_stats["destroy"]
	else:
		destroy = -1
	texture = data.texture 


func _set_active(val: bool):
	active = val
	if active:
		modulate.a = 1
	else:
		modulate.a = .5


func turn() -> void:
	destroy -= 1
	if destroy == 0:
		self.data = load("res://Assets/Buildings/Empty.tres")
