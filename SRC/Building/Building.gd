class_name Building
extends Resource

export var cost: int
export var texture: Texture
export var building: String
export var description: String
export var tags := []
export var can_disable := true
export var build_stats := {"destroy": 0, "properties": {"food": 0, "water": 0, "polution": 0}}
export var passive_stats := {
	"using": {"power": 0, "people": 0,},
	"generating": {"power": 0, "people": 0, "happyness": 0},
	"local_boost": {"happyness_max": {"tag": "suburban", "range": 2, "factor": 0, "min": 0}}
}
export var turn_stat := {"properties": {"food": 0, "water": 0, "polution": 0, "money": 0}}

