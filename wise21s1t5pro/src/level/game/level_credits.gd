tool
extends Control


func _ready() -> void:
	$texture_rect.visible = false


func _on_ChangeSceneButton_next_scene(scene_to_load) -> void:
	get_tree().change_scene(scene_to_load)


func _on_timer_timeout() -> void:
	$animation_player_menu.play("menu")
