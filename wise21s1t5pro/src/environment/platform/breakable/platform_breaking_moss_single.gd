extends Spatial

signal create_new()

export var is_breakable : bool = false
export var react_to_player : bool = false
export var react_to_enemy : bool = false
export var is_broken : bool = false
export var can_respawn : bool = false

onready var start_position : Vector3 = Vector3.ZERO
onready var timer = $armature/area/life_timer
export var life_timer = .2


func _ready():
	timer.set_wait_time(life_timer)
	start_position = get_translation()
	is_broken = false


func react_to(_react_to_player, _react_to_enemy, _can_respawn):
	react_to_player = _react_to_player
	react_to_enemy = _react_to_enemy
	can_respawn = _can_respawn


func start_animation():
	$animation_player.play("BREAKING")


func _on_area_body_entered(body: Node) -> void:
	if is_broken:
		return
	
	if react_to_enemy and body.has_method("capture_by_bubble"):
		timer.start()
	
	if react_to_player and body.has_method("get_input"):
		timer.start()
		body.on_platform = true

	if react_to_player and react_to_enemy:
		if body.is_physics_processing() == true:
			timer.start()
			if body.has_method("get_input"):
				body.on_platform = true


func _on_area_body_exited(body: Node) -> void:
	if body.has_method("get_input"):
		body.on_platform = false


func _on_life_timer_timeout() -> void:
	start_animation()


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "BREAKING":
		is_broken = true
		visible = false


func _on_visibility_notifier_screen_exited() -> void:
	#print("Platform left screen!", self)
	if is_broken and can_respawn:
		if $respawn_timer.get_time_left() <= 0:
			$respawn_timer.start()
			#print("Timer started")


func _on_respawn_timer_timeout() -> void:
	#print("Timer is done, is the platform broken: ", is_broken)
	if is_broken and can_respawn:
		emit_signal("create_new", start_position)
		#print("Creating a new platform!")
