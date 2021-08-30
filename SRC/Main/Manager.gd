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
	"power_used": 0,
	"power_max": 0,
	"food": 0,
	"water": 0,
	"polution": 0,
	"people": 0,
	"happyness": 0,
}

var score := 0
var day := 1

var selected: Control = null
var selected_menu := -1
var ground := 2 setget _set_ground


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
		elif selected_menu >= 0:
			building_menu.hide()
			menu_split.get_child(selected_menu*2+1).get_node("Selected").hide()
			building_menu_margin.get_child(selected_menu).hide()
			selected_menu = -1


func can_afford(placeable: String) -> bool:
	if placeable == "ground":
		return ground > 0
	elif placeable == "destroy":
		return true
	else:
		return load(placeable).cost <= resources.money


func draw_ui() -> void:
	var data = resources.duplicate()
	data["day"] = day
	data["score"] = score
	for value in data:
		get_node(ui_paths[value]).text = str(data[value])


func _on_NexTurn_pressed() -> void:
	day += 1
	day_label.text = "Day " + str(day)
	animator.play("Day")
	for building in buildings.get_children():
		building = building as BuildingNode	
		for data in building.data.turn_stat["properties"]:
			resources[data] += building.data.turn_stat["properties"][data]
	for data in resources:
		if resources[data] < 0:
			resources[data] = 0
	if day%5 == 0:
		self.ground += 1
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


func _on_Builder_placed(placed: String, data: Building) -> void:
	if placed == "ground":
		self.ground -= 1
	elif placed != "destroy":
		resources.money -= data.cost
	if not can_afford(placed):
		selected.hide()
		selected = null
		builder.building = ""
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
