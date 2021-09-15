extends Node2D


func _ready() -> void:
	$AnimationPlayer.play("Splash", -1, 0.1)


func _on_Play_pressed() -> void:
	get_tree().change_scene("res://SRC/Main/Main.tscn")


func _on_Instructions_pressed() -> void:
	get_tree().change_scene("res://SRC/Main/Instructions.tscn")
