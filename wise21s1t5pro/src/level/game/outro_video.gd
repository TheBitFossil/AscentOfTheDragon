extends Control

export (String, FILE) var credits_menu = "res://src/level/game/level_main_menu.tscn"

export var user_input = false
export var user_is_holding_to_skip = false
export var user_can_skip_intro = false

export var max_loading_bar_value = 100
export var loading_bar_fill_speed = 200

export var mouse_time_visible = 3


func _ready() -> void:
	$Skipper.hide()
	$outro_video.play()
	user_can_skip_intro = false
	$MouseTimer.wait_time = mouse_time_visible
	hide_mouse()


func _on_outro_video_finished() -> void:
	get_tree().change_scene(credits_menu)


func _on_InputTimer_timeout() -> void:
	user_input = true


func hide_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#print("hidden")


func show_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#print("Show")
	$MouseTimer.start()


func show_text():
	$Skipper.show()
	$Skipper/SkipIntroLabel.show()


func _input(event: InputEvent) -> void:
	if not user_input:
		return
	
	if event.is_action_type():
		show_text()
		show_mouse()
		$MouseTimer.start()
		$Skipper/TextTimer.start()
		user_can_skip_intro = true


func _process(delta: float) -> void:
	if user_can_skip_intro:
		if Input.is_action_pressed("jump"):
			user_holding_space(delta)
			$Skipper/ProgressBar.show()
			$MouseTimer.start()
		elif Input.is_action_just_released("jump"):
			$Skipper/ProgressBar.value = 0
			yield(get_tree().create_timer(1.2), "timeout")
			$Skipper/ProgressBar.hide()
			$MouseTimer.start()


func user_holding_space(delta):
	if $Skipper/ProgressBar.value < max_loading_bar_value:
		$Skipper/ProgressBar.value += loading_bar_fill_speed * delta
	elif $Skipper/ProgressBar.value >= max_loading_bar_value:
		$Skipper/ProgressBar.value = max_loading_bar_value
		get_tree().change_scene(credits_menu)


func _on_TextTimer_timeout() -> void:
	$Skipper/SkipIntroLabel.hide()
	

func _on_MouseTimer_timeout():
	hide_mouse()
	#print("Timer out!")
