extends Area

signal picked_up_key
var key_amount = 1
 

func pick_up_key():
	emit_signal("picked_up_key", self.key_amount)
	queue_free()
