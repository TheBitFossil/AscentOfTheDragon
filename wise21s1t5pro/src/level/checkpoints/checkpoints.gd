extends Spatial

signal new_spawn_location


func _on_Checkpoint_body_entered(body):
	if body.has_method("reset_position"):
		emit_signal("new_spawn_location", global_transform)
		#print("Spawn position set!")
