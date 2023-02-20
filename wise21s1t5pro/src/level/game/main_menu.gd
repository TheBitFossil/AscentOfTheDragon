tool
extends Control


var next_scene = ""
var is_outro : bool = false


# Mouse
export var set_mouse_hidden : bool = false
export var user_input_allowed : bool = false


func _ready():
	$fade.play_fade_forward(true)
	show_cursor()
	next_scene = null


func show_cursor():
	if Input.MOUSE_MODE_HIDDEN:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func button_access():
	for child in $options/menu/buttons.get_children():
		if child.has_method("activate_button"):
			child.activate_button(true)


func outro():
	is_outro = true
	$options/animation_player.play_backwards("fade")


func _on_change_scene_button_next_scene(scene) -> void:
	next_scene = scene
	outro()


func _on_fade_fade_finished() -> void:
	$volume.start_theme()

	if next_scene != null:
		get_tree().change_scene(next_scene)
		next_scene = null


func _on_animation_player_animation_finished(_anim_name: String) -> void:
		if not is_outro:
			return
		
		$fade.play_fade_forward(false)

