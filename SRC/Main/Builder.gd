class_name Builder
extends Sprite

signal placed(placed, data)

var snap_offset: Vector2
onready var ground_place: TileMap = get_node("../GroundPlace")
onready var ground: TileMap = get_node("../Ground")
onready var buildings: Node2D = get_node("../Buildings")

var building := "" setget _set_building
var build_data: Building


func _ready() -> void:
	ground_place.set_cellv(Vector2(0,0), 1)
	place_ground(Vector2(0,0))


func _set_building(value: String) -> void:
	building = value
	ground_place.hide()
	if building == "":
		texture = null
	elif building == "ground":
		ground_place.show()
		texture = load("res://Assets/Previews/Ground.png")
		snap_offset = Vector2(42,41.5)
	elif building == "destroy":
		pass
	else:
		snap_offset = Vector2(14,15)
		build_data = load(building)
		if build_data.texture:
			texture = build_data.texture


func _process(_delta: float) -> void:
	if building == "ground":
		position = ground_place.map_to_world(
			ground_place.world_to_map(get_global_mouse_position())
		) + snap_offset
	else:
		position = ground.map_to_world(
			ground.world_to_map(get_global_mouse_position())
		) + snap_offset


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place"):
		if building == "ground":
			var snapped := ground_place.world_to_map(get_global_mouse_position())
			if place_ground(snapped):
				emit_signal("placed", "ground", null)
		elif building == "destroy":
			pass
		elif building != "":
			var snapped := ground.world_to_map(get_global_mouse_position())
			if place_building(snapped):
				emit_signal("placed", building, build_data)


func place_building(point: Vector2) -> bool:
	var coord = Vector3(point.x-(point.y-(int(point.y)&1))/2, 0, point.y)
	coord.y = -coord.x-coord.z
	var node_name := str(coord.x)+"_"+str(coord.y)+"_"+str(coord.z)
	if not buildings.has_node(node_name):
		return false
	var node := buildings.get_node(node_name)
	if node.data.building == "empty":
		node.data = build_data
		return true
	return false


func place_ground(point: Vector2) -> bool:
	var snapped := ground.world_to_map(ground_place.map_to_world(point))
	if ground_place.get_cellv(point) == 1:
		ground_place.set_cellv(point, 2)
		for i in range(3):
			for j in range(3):
				if i > 0 or j == 1:
					var off_set := Vector2(i,j)
					if j == 1 and abs(int(snapped.y)%2) == 1:
						off_set.x += 1
					var p := snapped+off_set
					ground.set_cellv(p, 0)
					var new_building = BuildingNode.new()
					var coord = Vector3(p.x-(p.y-(int(p.y)&1))/2, 0, p.y)
					coord.y = -coord.x-coord.z
					new_building.name = str(coord.x)+"_"+str(coord.y)+"_"+str(coord.z)
					buildings.call_deferred("add_child", new_building)
					new_building.position = ground.map_to_world(p) + Vector2(14,15)
				if (i+j)%4 != 0 and ground_place.get_cellv(point+Vector2(i-1,j-1)) != 2:
					ground_place.set_cellv(point+Vector2(i-1,j-1), 1)
		return true
	return false

