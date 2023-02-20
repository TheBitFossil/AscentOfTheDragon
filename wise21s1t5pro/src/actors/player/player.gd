extends KinematicBody


signal player_bullet_fired
signal player_ammo_changed
signal player_health_changed
signal player_died

enum { CAPTURE, DAMAGE }

# Jumping
export var gravity : Vector3 = Vector3.DOWN * 90
export var initial_jump : float = 26.5
export var second_jump : float = 18.0
export var max_jump_height : float = 100.0
export var max_jumps : int = 2
onready var ray_ground : RayCast = $mesh/facing/raycast_ground
onready var double_jump_sign = $double_jump_sign
onready var double_jump_timer = $double_jump_timer
var jump_count : int = 0

#Falling
export var max_fall_speed : float = 25.0

# Moving
onready var animation_controller = $mesh/player
onready var facing = $mesh/facing
onready var metarig = $mesh/player/spatial/metarig
export var max_speed : float = 12.0
export var shoot_speed : float = 5.0
export var acceleration : float = .13
export var decceleration : float = 1.0
var velocity : Vector3 = Vector3.ZERO
var is_grounded : bool = false
var is_in_camera_view : bool = false
var on_platform : bool = false
var can_move : bool = true

# Shooting
export (PackedScene) var player_bullet
export var recharge_rate : float = 5.0
export var fire_rate : float = .75 
export var bullet_speed : float = 4.0
export var bullet_capture_time : float = 3.0
onready var muzzle = $mesh/facing/muzzle
onready var recharge_timer = $recharge_rate
onready var fire_rate_timer = $fire_rate
var current_ammo : int = 0
var max_ammo : int = 5
var can_shoot : bool = true
var is_shooting : bool = false

# Health
export var invulnerable_duration : float = 3.0
onready var invulnerable_timer = $invulnerable_timer
onready var player_health = $health_component
var is_alive : bool = true
var is_invulnerable : bool = false

# Loot
var lootable_in_range : bool = false
var lootable_item = null

# Unlocks
export var has_jump_unlocked : bool = false
export var has_double_jump_unlocked : bool = false

# Sound Effects
export (Array, AudioStream) var jump_sounds
onready var audioplayer_walk : AudioStreamPlayer = $audio_stream_walk
onready var audioplayer_jump : AudioStreamPlayer = $audio_stream_jump
onready var audioplayer_effect : AudioStreamPlayer = $audio_stream_effects


func start(pos : Transform, status):
	is_alive = status
	add_bullet(max_ammo)
	set_global_transform(pos)
	fire_rate_timer.wait_time = fire_rate
	recharge_timer.wait_time = recharge_rate
	invulnerable_timer.wait_time = invulnerable_duration

	emit_signal("player_ammo_changed", current_ammo)
	emit_signal("player_health_changed", get_current_health())
	audioplayer_jump.stream = jump_sounds[0]


func get_input():
	if Input.get_action_strength("left") and not is_shooting:
		move_left()
	elif Input.get_action_strength("right")  and not is_shooting:
		move_right()
	else:
		if not is_shooting:
			stop_movement()
			audioplayer_walk.stop()


	if Input.is_action_just_pressed("shoot_capture") and current_ammo != 0:
		is_shooting = true
		velocity.x = 0
		if can_shoot:
			can_shoot = false
			fire_rate_timer.start()
			animation_controller.transition_to(animation_controller.States.SHOOT)
			
	if has_jump_unlocked:
		if Input.is_action_just_pressed("jump"):
			if is_grounded or is_coyote_time_active() or on_platform:
				jump(initial_jump, velocity.x)
				audioplayer_jump.stream = jump_sounds[0]
				audioplayer_jump.play()
				jump_count += 1
			elif has_double_jump_unlocked:
				if jump_count < max_jumps:
					jump(second_jump, velocity.x)
					jump_count += 1
					audioplayer_jump.stream = jump_sounds[1]
					audioplayer_jump.play()
		if is_on_floor() and is_grounded or on_platform:
			jump_count = 0

	if not lootable_in_range or lootable_item == null:
		return
	else:
		if Input.is_action_just_pressed("action_interact"): 
			collect_item(lootable_item)
		elif Input.is_action_just_released("action_interact"):
			if lootable_in_range:
				lootable_item = null


func reset_position(location):
	set_global_transform(location)


func ground_detection():
	is_grounded = ray_ground.is_colliding()
	return is_grounded


func move_left():
	animation_controller.transition_to(animation_controller.States.RUN)
	facing.set_rotation_degrees(Vector3(0, 180, 0))
	metarig.rotation_degrees = facing.rotation_degrees
	velocity.x = lerp(velocity.x, -max_speed, acceleration)


func move_right():
	animation_controller.transition_to(animation_controller.States.RUN)
	facing.set_rotation_degrees(Vector3(0, 0, 0))
	metarig.rotation_degrees = facing.rotation_degrees
	velocity.x = lerp(velocity.x, max_speed, acceleration)


func stop_movement():
	if not is_invulnerable:
		animation_controller.transition_to(animation_controller.States.IDLE)
		
	velocity.x = lerp(velocity.x, 0, decceleration)


func play_walk_sound():
	if not audioplayer_walk.is_playing():
		audioplayer_walk.play()


func shoot():
	var b = player_bullet.instance()
	
	b.set_translation(muzzle.global_transform.origin)
	b.set_rotation_degrees(Vector3(0, facing.rotation_degrees.y, 0))
	b.set_speed(bullet_speed)
	b.set_capture_timer(bullet_capture_time)
	subtract_bullet(1)
	emit_signal("player_bullet_fired", b)
	
	start_bullet_recharge(recharge_rate)
	is_shooting = false


func start_bullet_recharge(time):
	recharge_timer.wait_time = time
	recharge_timer.start()


func reset_bullets():
	subtract_bullet(current_ammo)
	start_bullet_recharge(recharge_rate)


func start_double_jump_boost_timer(time):
	double_jump_timer.wait_time = time
	double_jump_sign.visible = true
	double_jump_timer.start()


func subtract_bullet(val):
	if current_ammo > 0:
		current_ammo -= val
	elif current_ammo <= 0:
		current_ammo = 0
	
	#can_shoot = false if current_ammo <= 0 else true
	emit_signal("player_ammo_changed", current_ammo)


func add_bullet(val):
	if current_ammo != max_ammo: 
		if (current_ammo + val) < max_ammo:
			current_ammo += val
		elif (current_ammo + val) >= max_ammo:
			current_ammo = max_ammo
	
	emit_signal("player_ammo_changed", current_ammo)


func get_current_health():
	return player_health.current_health


func unlock_jump(state):
	has_jump_unlocked = state


func unlock_double_jump(state):
	has_double_jump_unlocked = state


func jump(force, speed):
	velocity.y = force + abs(speed / 4.0)
	velocity.y = clamp(velocity.y, initial_jump, max_jump_height)


func is_coyote_time_active() -> bool:
	return $coyote_timer/timer.time_left > 0


func take_damage(amount):
	if is_invulnerable:
		return
		
	is_shooting = false
	is_invulnerable = true
	velocity.y = 12
	velocity.x = -8 * sign(velocity.x)
	animation_controller.transition_to(animation_controller.States.HURT)
	player_health.subtract_health(amount)
	audioplayer_effect.play()
	invulnerable_timer.start()


func collect_item(item):
	item.pickup()


func damage_by_enemy_bullet(id, amount):
	take_damage(amount)
	id.queue_free()


func _physics_process(delta):
	#if not is_grounded or is_on_floor():
	velocity += gravity * delta
	if velocity.y <= -max_fall_speed:
		velocity.y = -max_fall_speed
		
	ray_ground.force_raycast_update()
	
	if is_alive:
		ground_detection()
		if is_in_camera_view:
			get_input()
		
		velocity = move_and_slide(velocity, Vector3.UP)


func _on_FireRate_timeout():
	can_shoot = true


func _on_RechargeTimer_timeout():
	add_bullet(1)
	if current_ammo != max_ammo:
		recharge_timer.start()


func _on_InvulnerableTimer_timeout():
	is_invulnerable = false
	audioplayer_effect.stop()
	animation_controller.transition_to(animation_controller.States.IDLE)


func _on_enemy_detector_body_entered(body: Node) -> void:
	if body.has_method("drop_loot_when_captured"):
		if body.is_captured == true:
			body.drop_loot_when_captured()
	
	if body.has_method("_on_death"):
		if body.is_captured == true:
			body._on_death()
	
	if body.has_method("damage_Player"):
		if body.is_captured == false:
			body.damage_Player(self)


func _on_VisibilityNotifier_camera_exited(_camera):
	is_in_camera_view = false


func _on_VisibilityNotifier_camera_entered(_camera):
	is_in_camera_view = true


func _on_LootDetector_loot_detected(id, in_range):
	lootable_item = id
	lootable_in_range = in_range


func _on_DoubleJumpBoostTimer_timeout():
	has_double_jump_unlocked = false
	double_jump_sign.visible = false


func _on_health_component_changed(_hp) -> void:
	emit_signal("player_health_changed", _hp)


# Death / GameOver
func _on_health_component_died() -> void:
	#print("Player anim death trans!")
	animation_controller.transition_to(animation_controller.States.DIE)
	is_alive = false


# Player Animation Callbacks
func _on_player_death():
	if not is_alive:
		#print("Game End!")
		emit_signal("player_died", 	global_transform.origin)


func _on_player_anim_shoot():
	shoot()
