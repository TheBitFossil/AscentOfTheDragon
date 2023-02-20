extends Position3D

signal spawned_kotengu(object)

export (PackedScene) var Kotengu


func _process(delta):
	if Input.is_action_just_pressed("spawn_kotengu"):
		var k = Kotengu.instance()
		
		# Send Signal to root node with object
		emit_signal("spawned_kotengu", k)
