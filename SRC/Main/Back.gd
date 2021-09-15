extends TextureButton


func _on_Back_pressed() -> void:
	get_tree().change_scene("res://SRC/Main/MainMenu.tscn")
