extends KinematicBody

export var lever_used = false
export var can_be_used = false

onready var anim_elevator = $animation_player_elevator
onready var anim_lever = $clouds_3x1/animation_player_lever

var cur_pos : float = 0.0


func _input(event):
	if not can_be_used:
		return
	
	if event.is_action_pressed("action_interact") and can_be_used:
		if lever_used:# and not anim_lever.is_playing:
			anim_lever.play_backwards("change")
		else:
			anim_lever.play("change")


func _on_ElevatorButton_body_entered(body):
	if body.has_method("get_input"):
		can_be_used = true
		body.on_platform = true


func _on_ElevatorButton_body_exited(body):
	if body.has_method("get_input"):
		can_be_used = false
		body.on_platform = false


func _on_animation_player_lever_animation_finished(_anim_name):
	cur_pos = anim_elevator.current_animation_position
	
	if lever_used:
		anim_elevator.play("move")
		anim_elevator.seek(cur_pos)
	else:
		anim_elevator.play_backwards("move")
		anim_elevator.seek(cur_pos)



func _on_animation_player_elevator_animation_finished(anim_name):
	if anim_name == "move":
#		cur_pos = anim_elevator.current_animation_position
#		anim_elevator.stop(false)
#		anim_elevator.seek(cur_pos)
		pass
#	if anim_name == "move_to_end":
#		anim_elevator.play("idle_end")
#	elif anim_name =="move_to_start":
#		anim_elevator.play("idle_start")
