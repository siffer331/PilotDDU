extends Node2D

export var red: Color
export var green: Color

var icons := {
	"money": 0,
	"food": 4,
	"water": 3,
	"polution": 5,
	"power_max": 1,
	"happyness_max": 6,
	"people_max": 2,
}

func display(resource: String, value: int) -> void:
	if value == 0:
		$Icon.hide()
		$Hex.modulate = Color.white
		$Label.text = ""
		return
	$Label.text = str(value)
	$Icon.show()
	$Icon.frame = icons[resource]
	if resource == "polution":
		value *= -1
	if value < 0:
		$Hex.modulate = red
	else:
		$Hex.modulate = green
