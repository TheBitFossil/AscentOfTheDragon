extends Control


export var user_input : bool = false
export var main_menu = "res://src/level/game/level_main_menu.tscn"


func _ready() -> void:
	$fade.play_fade_forward(true)
	$any_key_label.hide()


func _on_fade_fade_finished() -> void:
	user_input = true
	$any_key_label.show()


func _input(event: InputEvent) -> void:
	if not user_input:
		return
	
	if event.is_action_type():
		get_tree().change_scene(main_menu)
