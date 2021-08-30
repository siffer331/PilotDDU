class_name BuildingNode
extends Sprite

var data: Building setget _set_building

func _ready() -> void:
	data = load("res://Assets/Buildings/Empty.tres")


func _set_building(_data: Building) -> void:
	data = _data
	texture = data.texture 


func turn() -> void:
	pass
