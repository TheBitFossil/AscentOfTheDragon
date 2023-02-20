extends TextureButton

signal next_scene()

export (String, FILE) var next_scene = ""
export var focus : bool = false


var input_allowed : bool = false


func _ready() -> void:
	input_allowed = false
	if focus:
		grab_focus()

func activate_button(value : bool):
	input_allowed = value


func _on_change_scene_button_button_down() -> void:
	$label.set("custom_colors/font_color", Color(1.0, 0.92, 0.87, 1.0))


func _on_change_scene_button_button_up() -> void:
	emit_signal("next_scene", next_scene)
	$label.set("custom_colors/font_color", Color(.26, .18, .22, 1.0))


func _on_change_scene_button_mouse_entered() -> void:
	if not input_allowed:
		return
		
	$audio_stream_player.play()
