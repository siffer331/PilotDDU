class_name Tooltip
extends MarginContainer

export var red: Color
export var green: Color

var paths := {
	"money": 3,
	"food": 11,
	"water": 9,
	"polution": 13,
	"power": 5,
	"happyness": 15,
	"people": 7,
}


func display(data: Building) -> void:
	var resources := {}
	for re in data.passive_stats["generating"]:
		if data.passive_stats["generating"][re] != 0:
			resources[re] = data.passive_stats["generating"][re]
	for re in data.passive_stats["using"]:
		if data.passive_stats["using"][re] != 0:
			resources[re] = -data.passive_stats["using"][re]
	for re in data.turn_stat["properties"]:
		if data.turn_stat["properties"][re] != 0:
			resources[re] = data.turn_stat["properties"][re]
	$Split/Cost/Label.text = str(data.cost)
	$Split/Building.text = data.building
	for key in resources:
		$Split.get_child(paths[key]).show()
		$Split.get_child(paths[key]-1).show()
		$Split.get_child(paths[key]).get_child(1).text = str(resources[key])
		if key == "polution":
			resources[key] *= -1
		if resources[key] < 0:
			$Split.get_child(paths[key]).get_child(1).modulate = red
		else:
			$Split.get_child(paths[key]).get_child(1).modulate = green
