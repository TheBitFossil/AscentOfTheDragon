extends Area

signal garbage_collected

func _on_OutOfBoundsCollector_body_entered(body):
	if body.has_method("damage_Player"):
		if body.is_dead == false:
			body.respawn()
		else:
			body.queue_free()
	elif body.has_method("take_damage"):
		emit_signal("garbage_collected", body)

