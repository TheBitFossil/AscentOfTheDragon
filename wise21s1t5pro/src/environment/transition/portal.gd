extends Area

signal player_reached_end()

var is_active : bool = false


func _on_Portal_body_entered(body):
	if body.has_method("get_input") and is_active:
		emit_signal("player_reached_end")


func set_active(state : bool):
	is_active = state
