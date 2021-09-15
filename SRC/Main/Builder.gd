class_name Builder
extends Sprite

signal placed(placed, data)
signal disabled

var snap_offset: Vector2
onready var ground_place: TileMap = get_node("../GroundPlace")
onready var ground: TileMap = get_node("../Ground")
onready var buildings: Node2D = get_node("../Buildings")

var building := "" setget _set_building
var build_data: Building
var r := 0

func _ready() -> void:
	ground_place.set_cellv(Vector2(0,0), 1)
	place_ground(Vector2(0,0))


func _set_building(value: String) -> void:
	building = value
	ground_place.hide()
	r = 0
	for child in get_children():
		child.queue_free()
	if building == "":
		texture = null
	elif building == "ground":
		ground_place.show()
		texture = load("res://Assets/Previews/Ground.png")
		snap_offset = Vector2(42,41.5)
	else:
		snap_offset = Vector2(14,15)
		build_data = load(building) as Building
		if build_data.texture:
			texture = build_data.texture
		for key in build_data.production_boost:
			r = max(r, build_data.production_boost[key]["range"])
		for key in build_data.local_boost:
			var arr = build_data.local_boost[key]
			if not arr is Array:
				arr = [arr]
			for data in arr:
				r = max(r, data["range"])
		for x in range(-r, r+1):
			for y in range(-r, r+1):
				var p := Vector3(x, y, -x-y)
				if (x == 0 and y == 0) or abs(p.z) > r:
					continue
				var node = load("res://SRC/Misc/BoostIndicator.tscn").instance()
				node.position.x = x*28+y*14
				node.position.y = y*23
				add_child(node)


func _process(_delta: float) -> void:
	if building == "ground":
		position = ground_place.map_to_world(
			ground_place.world_to_map(get_global_mouse_position())
		) + snap_offset
	else:
		var old := position
		position = ground.map_to_world(
			ground.world_to_map(get_global_mouse_position())
		) + snap_offset
		if (position-old).length_squared() > 4:
			var i = 0
			for child in get_children():
				child.display("", 0)
			for x in range(-r, r+1):
				for y in range(-r, r+1):
					var p := Vector3(x, y, -x-y)
					if (x == 0 and y == 0) or abs(p.z) > r:
						continue
					get_child(i).display("", 0)
					var point = ground.world_to_map(get_child(i).global_position)
					var b: BuildingNode = get_building(point)
					var dist = max(abs(p.x), max(abs(p.y), abs(p.z)))
					for tag in build_data.production_boost:
						var data = build_data.production_boost[tag]
						if data["range"] < dist:
							continue
						if (b and tag in b.data.tags) or (not b and tag == "water"):
							get_child(i).display(
								data["value"],
								data["min"] + (data["range"]-dist)*data["factor"]
							)
					for tag in build_data.local_boost:
						var arr = build_data.local_boost[tag]
						if not arr is Array:
							arr = [arr]
						for data in arr:
							if data["range"] < dist:
								continue
							if (b and tag in b.data.tags) or (not b and tag == "water"):
								get_child(i).display(
									data["value"],
									data["min"] + (data["range"]-dist)*data["factor"]
								)
					i += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place"):
		if building == "ground":
			var snapped := ground_place.world_to_map(get_global_mouse_position())
			if place_ground(snapped):
				emit_signal("placed", "ground", null, null)
		elif building != "":
			var snapped := ground.world_to_map(get_global_mouse_position())
			var old := place_building(snapped)
			if old:
				emit_signal("placed", building, build_data, old)
	if building == "" and event is InputEventMouseButton and event.doubleclick:
		var snapped := ground.world_to_map(get_global_mouse_position())
		var node := get_building(snapped)
		if node and node.data.can_disable:
			node.active = !node.active
			emit_signal("disabled")


func get_building(point: Vector2) -> BuildingNode:
	var coord = Vector3(int(point.x-(point.y-(int(point.y)&1))/2), 0, int(point.y))
	coord.y = int(-coord.x-coord.z)
	var node_name := str(coord.x)+"_"+str(coord.y)+"_"+str(coord.z)
	if not buildings.has_node(node_name):
		return null
	return buildings.get_node(node_name) as BuildingNode


func place_building(point: Vector2) -> Building:
	var node: BuildingNode = get_building(point)
	if node == null:
		return null
	if xor(node.data.building == "empty", build_data.building == "Construction site"):
		var old := node.data
		node.data = build_data
		return old
	return null


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
					var coord = Vector3(int(p.x-(p.y-(int(p.y)&1))/2), 0, int(p.y))
					coord.y = int(-coord.x-coord.z)
					new_building.name = str(coord.x)+"_"+str(coord.y)+"_"+str(coord.z)
					buildings.call_deferred("add_child", new_building)
					new_building.position = ground.map_to_world(p) + Vector2(14,15)
				if (i+j)%4 != 0 and ground_place.get_cellv(point+Vector2(i-1,j-1)) != 2:
					ground_place.set_cellv(point+Vector2(i-1,j-1), 1)
		return true
	return false


func xor(a: bool, b: bool) -> bool:
	return ((not (a and b)) and (a or b))
