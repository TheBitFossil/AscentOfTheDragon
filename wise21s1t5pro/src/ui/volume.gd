extends Control

export var theme_sound = preload("res://src/audio/title_screen.wav")
export var min_volume : float = -30.0
export var max_volume : float = 10.0
export var silence_volume : float = -60.0

onready var audio_player = $audio_stream_player


func _ready() -> void:
	audio_player.stream = theme_sound


func start_theme():
	if not audio_player.is_playing():
		audio_player.play()


func _on_volume_button_toggled(button_pressed):
	if button_pressed:
		audio_player.set_volume_db(silence_volume)
	else:
		audio_player.set_volume_db(0.0)


func _on_h_slider_value_changed(value: float) -> void:
	var vol = value
	vol = clamp(vol, min_volume, max_volume)
	audio_player.set_volume_db(vol)
