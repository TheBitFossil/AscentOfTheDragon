extends Control

signal game_paused

onready var pause_on_sfx = preload("res://src/audio/ui_pause_on.wav")
onready var pause_off_sfx = preload("res://src/audio/ui_pause_off.wav")


var is_paused = false


func _input(event):
	if event.is_action_pressed("game_paused"):
		toggle_mouse_mode()
		toggle_pause()
		play_sound_effect(is_paused)


func toggle_pause():
	is_paused = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	emit_signal("game_paused", is_paused)


func toggle_mouse_mode():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func play_sound_effect(_paused):
	if _paused:
		$AudioStreamPlayer.stream = pause_off_sfx
	else:
		$AudioStreamPlayer.stream = pause_on_sfx
	
	$AudioStreamPlayer.play()


func _on_QuitButton_button_up() -> void:
	get_tree().quit()


func _on_ChangeSceneButton_next_scene(_scene) -> void:
	if get_tree().paused == false:
		toggle_mouse_mode()
		get_tree().change_scene(_scene)
	else:
		toggle_mouse_mode()
		toggle_pause()
		play_sound_effect(is_paused)
		get_tree().change_scene(_scene)


func _on_ContinueButton_pause_mode():
	toggle_mouse_mode()
	toggle_pause()
	play_sound_effect(is_paused)
