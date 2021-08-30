class_name MoveableCamera
extends Camera2D

const ZOOM_FACTOR := 1.15
const MIN_ZOOM := 0.5
const MAX_ZOOM := 2

var is_panning := false
var focus_point: Vector2


func _process(delta: float) -> void:
	if is_panning:
		position += focus_point - get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pan"):
		is_panning = true
		focus_point = get_global_mouse_position()
	if event.is_action_released("pan"):
		is_panning = false
	if event is InputEventMouse and event.is_pressed():
		var distance := get_global_mouse_position() - position
		var old_scale := zoom.x
		if event.button_index == BUTTON_WHEEL_UP:
			zoom = Vector2(max(MIN_ZOOM, old_scale/ZOOM_FACTOR), max(MIN_ZOOM, old_scale/ZOOM_FACTOR))
			position += distance*(old_scale/zoom.x-1)
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom = Vector2(min(MAX_ZOOM, old_scale*ZOOM_FACTOR), min(MAX_ZOOM, old_scale*ZOOM_FACTOR))
			position += distance*(old_scale/zoom.x-1)
