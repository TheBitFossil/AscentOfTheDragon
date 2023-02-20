tool
extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_ChangeSceneButton_next_scene(scene) -> void:
	get_tree().change_scene(scene)
