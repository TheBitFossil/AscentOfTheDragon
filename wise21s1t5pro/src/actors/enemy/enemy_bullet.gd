extends RigidBody


var speed : float = 0.0
var damage : int = 3


func _ready() -> void:
	set_as_toplevel(true)


func set_speed(value):
	speed = value
 

func set_damage(value):
	damage = value


func set_life_timer(time):
	$GarbageCollectionTimer.wait_time = time


func collide_with_bubble():
	queue_free()


func _integrate_forces(_state):
	if rotation_degrees.y != 0.0:
		set_linear_velocity(Vector3(-speed, 0, 0))
	elif rotation_degrees.y == 0.0:
		set_linear_velocity(Vector3(speed, 0, 0))


func _on_GarbageCollectionTimer_timeout():
	queue_free()


func _on_VisibilityNotifier_screen_exited():
	queue_free()


func _on_Detector_body_entered(body):
	if body.has_method("damage_by_enemy_bullet"):
		body.damage_by_enemy_bullet(self, damage)
