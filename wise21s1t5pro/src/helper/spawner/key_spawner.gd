extends Position3D

signal key_spawned(item)


export (PackedScene) var keyfragment
export var key_spawned = false

func _ready():
	self.key_spawned = false


func _input(_event):
	if self.key_spawned: 
		return
	
	if Input.is_action_pressed("spawn_key"):
		spawn_keyfragment()


func spawn_keyfragment():
	if key_spawned:
		return

	var k = keyfragment.instance()
	k.set_global_transform(self.global_transform)
	emit_signal("key_spawned", k)
	self.key_spawned = true
