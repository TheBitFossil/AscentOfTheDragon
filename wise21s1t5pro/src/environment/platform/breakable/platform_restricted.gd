extends StaticBody

export var is_breakable = false
export var is_use_limited = false
export var react_to_player = false
export var react_to_enemy = false

export var life_timer = 2.0
export var max_velocity_before_breaking_x = 0.0 # when we have a speedvalue, we could react to it (sneak?!)
export var max_uses_alowed = 2


onready var timer = $LifeTimer
onready var anim  = $platform_breaking_moss/AnimationPlayer

var bodies_entered = 0
var is_broken = false
var can_be_walked_on = true


func _ready():
	timer.set_wait_time(life_timer)
	set_idle_anim(is_use_limited)


func set_idle_anim(limited):
	if limited:
		anim.play("IDLE")
	
	elif limited and not can_be_walked_on:
		anim.play("IDLE")
		#print("Used all Walks!")


func toggle_breakable(amount):
	if amount == max_uses_alowed:
		anim.play("IDLE")
	elif amount >= max_uses_alowed:
		can_be_walked_on = false
		
	#print("Max Bodies Entered: ", max_uses_alowed)


func _on_Area_body_entered(body):
	if not is_breakable:
		return
	
	if is_use_limited and can_be_walked_on:
		bodies_entered += 1
		toggle_breakable(bodies_entered)
		#print("Body in area entered:", bodies_entered)
	
	if is_use_limited and not is_broken and not can_be_walked_on:
		if react_to_enemy and body.has_method("capture_by_bubble"):
			timer.start()
	
		if react_to_player and body.has_method("get_input"):
			timer.start()

		if react_to_player and react_to_enemy:
			if body.is_physics_processing() == true:
				timer.start()


func _on_LifeTimer_timeout():
	anim.play("BREAKING")
	is_broken = true
	#print("Breaking", self.name)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "BREAKING":
		queue_free()
