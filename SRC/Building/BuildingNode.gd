class_name BuildingNode
extends Sprite

var data: Building setget _set_building
var destroy := -1

func _ready() -> void:
	data = load("res://Assets/Buildings/Empty.tres")


func _set_building(_data: Building) -> void:
	data = _data
	if "destroy" in data.build_stats:
		destroy = data.build_stats["destroy"]
	else:
		destroy = -1
	texture = data.texture 


func turn() -> void:
	destroy -= 1
	if destroy == 0:
		self.data = load("res://Assets/Buildings/Empty.tres")
