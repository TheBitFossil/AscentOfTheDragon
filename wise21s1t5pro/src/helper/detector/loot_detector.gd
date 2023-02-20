extends Area

signal loot_detected

var detected_loot = null
var loot_nearby = false

var detected_shard = null
var shard_nearby = false


func _on_LootDetector_area_entered(area):
	if area.has_method("pickup"):
		detected_loot = area
		loot_nearby = true
		emit_signal("loot_detected", detected_loot, loot_nearby)
	
	if area.has_method("set_shard_value"):
		detected_shard = area
		shard_nearby = true
		
		if area.shard_active:
			area.gather_shard()

	if area.has_method("pick_up_key"):
		area.pick_up_key()



func _on_LootDetector_area_exited(area):
	if area.has_method("pickup"):
		detected_loot = null
		loot_nearby = false
		emit_signal("loot_detected", detected_loot, loot_nearby)

