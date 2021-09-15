extends TextureButton


export var data_path := ""


func _make_custom_tooltip(for_text: String) -> Control:
	var node: Tooltip = load("res://SRC/UI/Tooltip.tscn").instance()
	node.display(load(data_path))
	return node



