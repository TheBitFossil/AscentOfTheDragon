extends KinematicBody


"""
	A special Enemy AI: It will unlock the jumping for the Player
"""

signal on_death

onready var bubble = $player_bubble

var is_captured = false
var velocity = Vector3.ZERO


func _ready():
	$EnemyKotengu/AnimationPlayer.play("IDLE_STAND")


func _physics_process(_delta):
	if is_captured:
		return



func capture_by_bubble(time_captured):
	is_captured = true
	
	$CaptureTimer.set_wait_time(time_captured)
	$CaptureTimer.start()
	bubble.show()
	$EnemyKotengu/AnimationPlayer.play("CAPTURED")


func _on_CaptureTimer_timeout():
	is_captured = false
	bubble.hide()
	$EnemyKotengu/AnimationPlayer.play("IDLE_STAND")


func _on_death():
	if is_captured:
		emit_signal("on_death")
		queue_free()


func _on_screen_exited():
	set_physics_process(false)


func _on_screen_entered():
	set_physics_process(true)
