extends ColorRect


signal fade_finished


func play_fade_forward(forward : bool):
	if forward:
		$animation_player.play("fade")
	else:
		$animation_player.play_backwards("fade")


func _on_animation_player_animation_finished(_anim_name: String) -> void:
	emit_signal("fade_finished")
