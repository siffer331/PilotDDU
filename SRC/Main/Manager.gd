class_name Manager
extends Node

export var builder_path: NodePath
export var ground_selected_path: NodePath
export var ground_counter_path: NodePath
export var building_menu_path: NodePath
export var building_menu_margin_path: NodePath
export var menu_split_path: NodePath
export var animator_path: NodePath
export var day_label_path: NodePath
export var ui_paths: Dictionary
export var buildings_path: NodePath
export var popup_path: NodePath
export var end_path: NodePath
export var end_score_path: NodePath
export var red: Color
export var green: Color

onready var end_score: Label = get_node(end_score_path)
onready var end: Control = get_node(end_path)
onready var popup: Popup = get_node(popup_path)
onready var buildings := get_node(buildings_path)
onready var menu_split = get_node(menu_split_path)
onready var building_menu_margin = get_node(building_menu_margin_path)
onready var building_menu: Control = get_node(building_menu_path)
onready var ground_counter: Label = get_node(ground_counter_path)
onready var ground_selected := get_node(ground_selected_path)
onready var day_label: Label = get_node(day_label_path)
var builder: Builder
var animator: AnimationPlayer

var resources := {
	"money": 50,
	"food": 0,
	"water": 0,
	"polution": 0,
}

var change := {
	"money": 0,
	"food": 0,
	"water": 0,
	"polution": 0,
}

var passive := {
	"power_used": 0,
	"power_max": 0,
	"happyness_max": 0,
	"people_max": 0,
	"people_used": 0,
}


var score := 0
var day := 1

var selected: Control = null
var selected_menu := -1
var ground := 0 setget _set_ground


func _ready() -> void:
	draw_ui()
	builder = get_node(builder_path)
	animator = get_node(animator_path)
	ground_counter.text = str(ground)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("deselect"):
		if builder.building != "":
			builder.building = ""
			ground_selected.hide()
			selected.hide()
		elif selected_menu >= 0:
			building_menu.hide()
			menu_split.get_child(selected_menu*2+1).get_node("Selected").hide()
			building_menu_margin.get_child(selected_menu).hide()
			selected_menu = -1


func can_afford(placeable: String) -> bool:
	if placeable == "ground":
		return ground > 0
	else:
		return load(placeable).cost <= resources.money


func calculate_passive() -> void:
	for value in passive:
		passive[value] = 0
	for building in buildings.get_children():
		building = building as BuildingNode
		if not building.active:
			continue
		for key in building.data.passive_stats["generating"]:
			passive[key+"_max"] += building.data.passive_stats["generating"][key]
		for key in building.data.passive_stats["using"]:
			passive[key+"_used"] += building.data.passive_stats["using"][key]
		#Calculate boosts
		var pos = string_to_vec(building.name)
		for tag in building.data.local_boost:
			var arr = building.data.local_boost[tag]
			if not arr is Array:
				arr = [arr]
			for data in arr:
				for x in range(-data["range"], data["range"]+1):
					for y in range(-data["range"], data["range"]+1):
						var p := Vector3(x, y, -x-y)
						if (x == 0 and y == 0) or abs(p.z) > data["range"]:
							continue
						if buildings.has_node(vec_to_string(p+pos)):
							var node: BuildingNode = buildings.get_node(vec_to_string(p+pos))
							if tag in node.data.tags:
								var dist = max(abs(p.x), max(abs(p.y), abs(p.z)))
								passive[data["value"]] += (
									data["min"] + (data["range"]-dist)*data["factor"]
								)


func draw_ui() -> void:
	var data = resources.duplicate()
	for key in passive:
		data[key] = passive[key]
	data["day"] = day
	data["score"] = score
	for key in passive:
		data[key] = passive[key]
	for value in data:
		var val = data[value]
		var node = get_node(ui_paths[value])
		node.text = str(val)
		if value in change:
			var change_node = node.get_child(0)
			if change[value] > 0:
				change_node.text = "+" + str(change[value])
			else:
				change_node.text = str(change[value])
			var v = change[value]
			if value == "polution":
				v *= -1
			if v < 0:
				change_node.modulate = red
			elif v > 0:
				change_node.modulate = green
			else:
				change_node.modulate = Color.white

func calculate_change() -> void:
	for x in change:
		change[x] = 0
	for building in buildings.get_children():
		building = building as BuildingNode
		if not building.active:
			continue
		for data in building.data.turn_stat["properties"]:
			change[data] += building.data.turn_stat["properties"][data]
		#Calculate boosts
		var pos = string_to_vec(building.name)
		for tag in building.data.production_boost:
			var data = building.data.production_boost[tag]
			for x in range(-data["range"], data["range"]+1):
				for y in range(-data["range"], data["range"]+1):
					var p := Vector3(x, y, -x-y)
					if (x == 0 and y == 0) or abs(p.z) > data["range"]:
						continue
					var dist = max(abs(p.x), max(abs(p.y), abs(p.z)))
					if buildings.has_node(vec_to_string(p+pos)):
						var node: BuildingNode = buildings.get_node(vec_to_string(p+pos))
						if tag in node.data.tags:
							change[data["value"]] += (
								data["min"] + (data["range"]-dist)*data["factor"]
							)
					elif tag == "water":
						change[data["value"]] += (
							data["min"] + (data["range"]-dist)*data["factor"]
						)
	change["polution"] = clamp(change["polution"],-resources["polution"], 200-resources["polution"])

func _on_NexTurn_pressed() -> void:
	if day == 49:
		end.show()
		end_score.text = str(score)
		if score >= 2500:
			end_score.text += "\n Please post this result in #fun"
			var http = get_node("../HTTP")
			var body = to_json({"msg":"Victory!!!","channel_id":941343285912408166})
			var error = http.request("http://167.71.38.238:8090/msg ", [], true, HTTPClient.METHOD_POST, body)
			print(error)
	calculate_passive()
	
	var succesfull = true
	for data in resources:
		if resources[data]+change[data] < 0:
			succesfull = false
			break
	for key in ["power", "people"]:
		if passive[key+"_used"] > passive[key+"_max"]:
			succesfull = false
			break
	if not succesfull:
		popup.popup()
		return
	for data in resources:
		resources[data] += change[data]
	score += floor((passive.happyness_max*20/(resources.polution+1))/200)*5
	for building in buildings.get_children():
		building = building as BuildingNode
		if building.active:
			building.turn()
	day += 1
	day_label.text = "Day " + str(day)
	animator.play("Day")
	if day%5 == 0:
		self.ground += 1
	calculate_passive()
	draw_ui()


func _on_Placeable_pressed(placeable: String, selected_path: String) -> void:
	if selected:
		selected.hide()
	selected = get_node(selected_path)
	if placeable == builder.building or not can_afford(placeable):
		selected = null
		builder.building = ""
	else:
		selected.show()
		builder.building = placeable


func _set_ground(value: int) -> void:
	ground = value
	ground_counter.text = str(value)


func _on_Builder_placed(placed: String, data: Building, old: Building) -> void:
	if placed == "ground":
		self.ground -= 1
	else:
		for property in data.build_stats["properties"]:
			resources[property] += data.build_stats["properties"][property]
		resources.money -= data.cost - old.cost*2/3
	if not can_afford(placed):
		selected.hide()
		selected = null
		builder.building = ""
	calculate_change()
	calculate_passive()
	draw_ui()


func _on_Menu_pressed(menu: int) -> void:
	if selected_menu != -1:
		building_menu.hide()
		menu_split.get_child(selected_menu*2+1).get_node("Selected").hide()
		building_menu_margin.get_child(selected_menu).hide()
	if menu != selected_menu:
		building_menu.rect_position.x = 6 + 38*menu
		building_menu.show()
		building_menu_margin.get_child(menu).show()
		building_menu.rect_size.x = 0
		menu_split.get_child(menu*2+1).get_node("Selected").show()
		selected_menu = menu
	else:
		selected_menu = -1


static func string_to_vec(val: String) -> Vector3:
	var res := Vector3(0,0,0)
	var k := val.split("_")
	res.x = float(k[0])
	res.y = float(k[1])
	res.z = float(k[2])
	return res


static func vec_to_string(val: Vector3) -> String:
	return str(int(val.x)) + "_" + str(int(val.y)) + "_" + str(int(val.z))


func _on_Builder_disabled() -> void:
	calculate_change()
	calculate_passive()
	draw_ui()

