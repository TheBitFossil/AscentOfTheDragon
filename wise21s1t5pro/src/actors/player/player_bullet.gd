extends RigidBody

var speed = 2.0
var time_captured = 5.0
var damage = 1.0

var velocity = Vector3.ZERO


var is_capturing := false
var is_damaging := false


func _ready() -> void:
	set_as_toplevel(true)
	$AudioStreamPlayer.play()


func set_speed(value):
	speed = value


func set_capture_timer(time):
	time_captured = time


func _integrate_forces(_state):
	if rotation_degrees.y != 0.0:
		set_linear_velocity( Vector3(-speed, 0, 0) )
	elif rotation_degrees.y == 0.0:
		set_linear_velocity( Vector3(speed, 0, 0) )


func _on_Bubble_body_entered(body: Node) -> void:
	if body.has_method("capture_by_bubble"):
		body.capture_by_bubble(time_captured)
		queue_free()
		$AudioStreamPlayer.stop()
	elif body.has_method("collide_with_bubble"):
		body.collide_with_bubble()
		#print("Other bubble")
		$AudioStreamPlayer.stop()
	elif body.name == "Player":
		return
	else:
		queue_free()
		$AudioStreamPlayer.stop()


func _on_GarbageCollectionTimer_timeout():
	queue_free()
	$AudioStreamPlayer.stop()


func _on_VisibilityNotifier_screen_exited():
	queue_free()
