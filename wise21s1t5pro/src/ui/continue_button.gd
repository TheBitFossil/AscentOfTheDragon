extends TextureButton

signal pause_mode()

export var focus : bool = false 


func _ready() -> void:
	if focus:
		grab_focus()

func _on_ContinueButton_button_up() -> void:
	$label.set("custom_colors/font_color", Color(.26, .18, .22, 1.0))
	emit_signal("pause_mode")

func _on_ContinueButton_button_down():
	$label.set("custom_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
