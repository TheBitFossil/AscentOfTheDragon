extends Control

export var time_visible = 5.0
export var is_active = false


func _ready():
	$timer.wait_time = time_visible


func show_banner(kirin : bool):
	if kirin:
		$animation_player.play("fade_in")
		$kirin.visible = true
		$dragon.visible = false
	else:
		$animation_player.play("fade_in")
		$kirin.visible = false
		$dragon.visible = true


func set_text(text):
	$rich_text_label.set_bbcode(text)


func _on_timer_timeout():
	$animation_player.play("fade_out")
