extends Spatial

signal picked_up

onready var anim_shard = $crystal_pickup/animation_player

var shard_active = false
var value


func _ready():
	anim_shard.play("crystal_spin")


func set_shard_value(amount):
	value = amount


func _on_SetActiveTimer_timeout():
	if value != null:
		shard_active = true


func gather_shard():
	emit_signal("picked_up", self.value)
	queue_free()
