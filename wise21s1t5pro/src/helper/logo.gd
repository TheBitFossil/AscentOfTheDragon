extends Control


func _on_timer_timeout() -> void:
	$logo/animation_player.play("fade")
