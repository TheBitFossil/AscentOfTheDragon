extends Spatial

signal picked_up


export var jump_boost_time : float = 5.0
export var is_double_jump_boost : bool = true


func _on_Area_body_entered(body):
	if body.has_method("collect_item"):
		$sign.visible = true


func _on_Area_body_exited(body):
	if body.has_method("collect_item"):
		$sign.visible = false


func pickup():
	emit_signal("picked_up", 
			is_double_jump_boost, 
			jump_boost_time
	)
	queue_free()
