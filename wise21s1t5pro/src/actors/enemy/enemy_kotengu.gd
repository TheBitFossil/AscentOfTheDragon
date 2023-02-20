extends KinematicBody

signal loot_dropped(item)
signal enemy_fired(bullet)


enum { RIGHT, LEFT, IDLE, ATTACK, CAPTURED }
var state

# Movement
export var speed : float = 4.0
export var acceleration : float = 0.12
export var idle_speed: float = 0.0
export var gravity : float = -98.0

onready var model_anim = $enemy_kotengu/AnimationPlayer
onready var start_pos : Vector3  = Vector3.ZERO

var velocity : Vector3 = Vector3.ZERO

# Health
export var shard_drop_value : int = 1
export var damage_to_player : int = 1
var is_dead : bool = false

# Attack
export var bullet_timer : float = .5
export var bullet_speed : float = 4.0
var can_shoot : bool = true

# Timer
export var edge_patrol_time : float = 2.0
export var fire_rate : float = .8
onready var capture_timer : Timer = $capture_timer
onready var edge_timer : Timer = $edgepatrol_timer

# Captured
var is_captured : bool = false
onready var bubble = $player_bubble

# RayCast
onready var ray_wall : RayCast = $world_detection/wall
onready var ray_edge_front : RayCast = $world_detection/edge_front
onready var ray_edge_back : RayCast = $world_detection/edge_back
onready var ray_stairs : RayCast = $world_detection/stairs
var is_at_edge : bool = false

# Target
onready var target = null
export (PackedScene) var bullet

# Loot
export (PackedScene) var loot_drop

# Sound
export (Array, AudioStream) var capture_sounds


func _ready():
	set_move_animation(LEFT)
	$fire_rate.wait_time = fire_rate
	$edgepatrol_timer.wait_time = edge_patrol_time
	start_pos = global_transform.origin


func _physics_process(delta):
	if is_captured or is_dead:
		return
	
	if !is_on_floor():
		velocity.y += gravity * delta
	
	ray_wall.force_raycast_update()
	ray_edge_front.force_raycast_update()
	ray_edge_back.force_raycast_update()
	ray_stairs.force_raycast_update()
	
	set_move_animation(state)
	
	get_raycast_wall_detection()
	get_raycast_edge_detection()
	
	is_at_edge_check()
	check_for_target()
	move_and_slide(velocity, Vector3.UP)


func set_move_animation(_state):
	var dir = _state
	
	match dir:
		RIGHT:
			move_right()
			model_anim.play("WALK")
		LEFT:
			move_left()
			model_anim.play("WALK")
		IDLE:
			move_stop()
			model_anim.play("IDLE_STAND")
		ATTACK:
			move_stop()
			model_anim.play("ATTACK_DISTANCE")
		CAPTURED:
			move_stop()
			model_anim.play("CAPTURED")

	state = dir


func get_raycast_wall_detection():
	if is_dead:
		return
		
	var normal = ray_wall.get_collision_normal()
	
	# Move Left
	if ray_wall.is_colliding() and velocity.x < 0.0:
		if normal.x > 0.0:
			set_move_animation(RIGHT)
			
	# Move Right
	if ray_wall.is_colliding() and velocity.x > 0.0:
		if normal.x < 0.0:
			set_move_animation(LEFT)


func get_raycast_edge_detection():
	if is_dead:
		return
		
	if  ray_edge_back.is_colliding():
		if not ray_edge_front.is_colliding():
			if $edgepatrol_timer.is_stopped() and is_captured == false:
				set_move_animation(IDLE)
				$edgepatrol_timer.start()


func is_at_edge_check() -> bool:
	is_at_edge != ray_edge_front.is_colliding()
	return is_at_edge


func check_for_target() -> bool:
	var bodies = $player_detection.get_overlapping_bodies()
	
	for body in bodies:
		if body.has_method("subtract_health"):
			target = body
			#print("Target found!")
			return target
		else:
			target = null
			#print("Target null")
			return target
	
	return target


func respawn():
	set_translation(start_pos)


func move_left():
	velocity.x = lerp(velocity.x, -speed, acceleration)
	set_rotation_degrees(Vector3(0, 179.9, 0))


func move_right():
	velocity.x = lerp(velocity.x, speed, acceleration)
	set_rotation_degrees(Vector3(0, 0, 0))


func move_stop():
	velocity.x = lerp(velocity.x, 0.0, acceleration)


func capture_by_bubble(time_captured):
	is_captured = true
	capture_timer.set_wait_time(time_captured) 
	capture_timer.start()
	set_move_animation(IDLE)
	$AudioStreamPlayer_Effects.stream = capture_sounds[0]
	$AudioStreamPlayer_Effects.play()
	set_move_animation(CAPTURED)
	
	edge_timer.set_paused(true)
	bubble.show()


func damage_Player(id):
	if id.has_method("take_damage"):
		id.take_damage(damage_to_player)


func drop_loot_when_captured():
	var drop = loot_drop.instance()
	if is_captured:
		drop.set_global_transform(global_transform)
		drop.set_shard_value(shard_drop_value)

		emit_signal("loot_dropped", drop)
		is_dead = true
		queue_free()


func _on_enemy_kotengu_attack():
	shooting_from_animation()


func shooting_from_animation():
	shoot()
	can_shoot = false
	$fire_rate.start()


func shoot():
	if is_captured:
		return
	
	var b = bullet.instance()
	
	b.set_translation($muzzle.global_transform.origin)
	b.set_rotation_degrees(Vector3(0, rotation_degrees.y, 0))
	b.set_speed(bullet_speed)
	b.set_damage(damage_to_player)
	b.set_life_timer(bullet_timer)
	
	emit_signal("enemy_fired", b)


func resume_in_last_direction():
	#print("resuming in direction are we atr edge yet:" , is_at_edge_check())
	if not is_at_edge_check():
		if rotation_degrees.y > 0.0:
			set_move_animation(RIGHT)
		elif rotation_degrees.y == 0.0:
			set_move_animation(LEFT)


func _on_CaptureTimer_timeout():
	is_captured = false
	bubble.hide()
	
	edge_timer.set_paused(false)
	$AudioStreamPlayer_Effects.stream = capture_sounds[1]
	$AudioStreamPlayer_Effects.play()
	
	if check_for_target():
		set_move_animation(ATTACK)
	else:
		set_move_animation(IDLE)
		$resume_action_timer.start()
		#print("Timer started after target loss, captured", target)


func _on_player_detection_body_entered(body: Node) -> void:
	if is_captured:
		return

	set_move_animation(IDLE)

	if body.has_method("subtract_health"):
		target = body
	elif body.has_method("subtract_health") and body.is_invulnerable:
		set_move_animation(IDLE)

	if target:
		set_move_animation(ATTACK)


func _on_player_detection_body_exited(body: Node) -> void:
	if is_captured:
		return
	
	if body.has_method("subtract_health"):
		target = null
		set_move_animation(IDLE)
		$resume_action_timer.start()



func _on_EdgePatrolTimer_timeout():
	if rotation_degrees.y > 0.0:
		set_move_animation(RIGHT)
	elif rotation_degrees.y == 0.0:
		set_move_animation(LEFT)


func _on_FireRate_timeout():
	if is_captured:
		return
		
	can_shoot = true
	
	if can_shoot and target != null:
		set_move_animation(ATTACK)


# Garbage Collection
func _on_screen_exited():
	set_physics_process(false)


func _on_screen_entered():
	set_physics_process(true)


func _on_resume_action_timer_timeout() -> void:
	resume_in_last_direction()
