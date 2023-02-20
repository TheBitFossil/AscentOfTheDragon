extends Spatial

onready var anim = $AnimationPlayer
onready var reset_timer = $Timer
onready var red_plate = $Area/pressure_plate_ground_red
onready var green_plate = $Area/pressure_plate_ground_green
onready var green_anim = $Area/pressure_plate_ground_green/AnimationPlayer

export var time_to_count_down = 2.0
export var time_to_reset = 3.0


export var is_downward_moving = false
var is_downward_stopped = false
var is_idle_stopped = true
var has_been_triggered = false


func _ready():
	reset_timer.set_wait_time(time_to_reset)
	is_idle_stopped = true


func _on_area_body_entered(body: Node) -> void:
	if body.name == "Player" and not has_been_triggered:
		if not is_downward_moving:
			has_been_triggered = true
			red_plate.hide()
			green_anim.play("PRESSING")
			yield(get_tree().create_timer(time_to_count_down), "timeout")
			anim.play("move_up")
			#reset_timer.start()
		else:
			has_been_triggered = true
			red_plate.hide()
			green_anim.play("PRESSING")
			yield(get_tree().create_timer(time_to_count_down), "timeout")
			anim.play("move_down")
			#reset_timer.start()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "move_up":
		is_downward_stopped = false
	elif anim_name == "move_down":
		is_downward_stopped = true


#Only use this timer, when we want the platform to move back!
func _on_Timer_timeout():
#	anim.play("move_idle")
#	has_been_triggered = false
	pass
