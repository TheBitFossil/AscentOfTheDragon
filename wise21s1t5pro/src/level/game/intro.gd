extends Control


export var main_menu = preload("res://src/level/game/level_main_menu.tscn") 
export var level_001 = preload("res://src/level/game/level_001.tscn")
export var level_credits = preload("res://src/level/game/level_credits.tscn")
export  var level_end = preload("res://src/level/game/level_end_menu.tscn")
export var level_any_key = preload("res://src/level/game/level_any_key.tscn")

export var max_loading_bar_value : int = 100
export var loading_bar_fill_speed : int = 200
export var mouse_time_visible : int = 3

export var user_input : bool = false
export var user_is_holding_to_skip : bool = false
export var user_can_skip_intro : bool = false

onready var skipper_bar = $skipper/progress_bar
onready var skipper_label = $skipper/skip_label
onready var mouse_timer = $mouse_timer


func _ready() -> void:
	$skipper.hide()
	$intro_video.play()
	user_can_skip_intro = false
	mouse_timer.wait_time = mouse_time_visible
	hide_mouse()


func hide_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func show_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_timer.start()


func show_text():
	$skipper.show()
	skipper_label.show()


func _input(event: InputEvent) -> void:
	if not user_input:
		return
	
	if event.is_action_type():
		show_text()
		show_mouse()
		mouse_timer.start()
		$skipper/text_timer.start()
		user_can_skip_intro = true


func _process(delta: float) -> void:
	if user_can_skip_intro:
		if Input.is_action_pressed("jump"):
			user_holding_space(delta)
			skipper_bar.show()
			mouse_timer.start()
		elif Input.is_action_just_released("jump"):
			skipper_bar.value = 0
			yield(get_tree().create_timer(1.2), "timeout")
			skipper_bar.hide()
			mouse_timer.start()


func user_holding_space(delta):
	if skipper_bar.value < max_loading_bar_value:
		skipper_bar.value += loading_bar_fill_speed * delta
	elif skipper_bar.value >= max_loading_bar_value:
		skipper_bar.value = max_loading_bar_value
		get_tree().change_scene_to(level_any_key)


func _on_mouse_timer_timeout():
	hide_mouse()


func _on_input_timer_timeout() -> void:
	user_input = true


func _on_text_timer_timeout() -> void:
	skipper_label.hide()


func _on_intro_video_finished() -> void:
	get_tree().change_scene_to(level_any_key)
