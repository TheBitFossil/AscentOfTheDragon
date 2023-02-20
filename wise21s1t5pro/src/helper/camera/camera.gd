extends Camera


signal target_reached_y_bound()
signal target_reached_x_bound()


# Target
export (NodePath) var targetPath
onready var target_node = get_node(targetPath)

# Camera Follow Speed
export var vertical_follow_speed = 20.0
export var horizontal_follow_speed = 25.0
var cameraPos = Vector3.ZERO


# Drag Margins
export var max_dist_drag_x_axis = 5.0
export var max_dist_drag_y_axis = 2.0

var distance_to_target = Vector2.ZERO
var target_pos = Vector3.ZERO
var player_is_falling = false

# Offset to Player Model and Viewsize
export (float) var cameraPosZ = 30.0

# Where the Camera should stop the Players Vision
export var min_bound_x = 16.5
export var max_bound_x = 143.0

export var min_bound_y = -5.0
export var max_bound_y = 30


func _ready():
	set_camera_pos_z(cameraPosZ)
	target_pos = target_node.global_transform.origin


func _process(delta):
	target_pos = target_node.global_transform.origin
	
	calculate_distance_to(target_node)
	
	clamp_camera_bounds()
	
	set_camera_offset_when_player_falls()
	
	# Horizontal Movement, Follow Target (Drag Margin)
	if calculate_distance_to(target_node).x > max_dist_drag_x_axis:
		var new_horCameraPos = global_transform.origin.move_toward(
			Vector3(
				target_pos.x,
				global_transform.origin.y,
				cameraPosZ),
			delta * horizontal_follow_speed
		)
		
		cameraPos.x = new_horCameraPos.x

	# Vertical Movement, Follow Target (Drag Margin)
	if calculate_distance_to(target_node).y > max_dist_drag_y_axis:
		var new_verticalCameraPos = global_transform.origin.move_toward(
			Vector3(
				cameraPos.x, 
				target_pos.y, 
				cameraPosZ
			), 
			delta * vertical_follow_speed
		)
		cameraPos.y = new_verticalCameraPos.y
	
	global_transform.origin = cameraPos


func has_target_reached_end_of_camera(_target):
	if _target == null:
		return
	
	if _target.global_transform.origin.x < min_bound_x:
		emit_signal("target_reached_x_bound", _target, min_bound_x)
	
	if _target.global_transform.origin.y < min_bound_y:
		emit_signal("target_reached_y_bound", _target, min_bound_y)


func calculate_distance_to(_target):
	var distance = global_transform.origin - _target.global_transform.origin
	
	if distance == null:
		return
	
	return distance


func set_camera_pos_z(distance):
	global_transform.origin.z = distance


func clamp_camera_bounds():
	if global_transform.origin.y < min_bound_y:
		global_transform.origin.y = min_bound_y
	
	if global_transform.origin.x < min_bound_x:
		global_transform.origin.x = min_bound_x 


func set_camera_offset_when_player_falls():
	if player_is_falling:
		v_offset = lerp(get_v_offset(), 0.0, .75 * get_physics_process_delta_time())
	else:
		v_offset = lerp(get_v_offset(), 5.0, .2  * get_physics_process_delta_time())
