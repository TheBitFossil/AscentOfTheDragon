extends Area


onready var coyote_timer = $timer
var is_grounded = false


func _physics_process(_delta):
	$ray_cast.force_raycast_update()
	is_grounded = $ray_cast.is_colliding()


func stop_coyote():
	coyote_timer.stop()


func _on_coyote_timer_body_exited(_body: Node) -> void:
	var bodies = get_overlapping_bodies()
	if bodies == [] and not is_grounded:
		coyote_timer.start()
