tool
extends TextureButton

var input_allowed : bool = false


func _ready() -> void:
	input_allowed = false


func activate_button(value : bool):
	input_allowed = value


func _on_quit_button_button_up() -> void:
	if not input_allowed:
		return
		
	get_tree().quit()


func _on_quit_button_mouse_entered() -> void:
	if not input_allowed:
		return
		
	$audio_stream_player.play()


func _on_quit_button_button_down() -> void:
	$label.set("custom_colors/font_color", Color(1.0, 0.92, 0.87, 1.0))

