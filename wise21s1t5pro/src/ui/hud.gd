extends CanvasLayer


export (String) var cage_idle_text = "This cage is closed, you need to find the missing [b][color=#733272]keyparts[/color][/b] to free the Tiger !"
export (String) var cage_keys_text = "This cage is opened, you found the missing [b][color=#733272]keyparts[/color][/b] go and rescue Byakko !"
export (String) var tiger_rescued_text = "Thanks to you i am[b][color=#733272] free [/color][/b] now! Then lets go to the tunnel in the east to free [b][color=#733272] Genbu [/color][/b]!"


func _on_Player_shard_picked_up(value):
	$HUD/PointsBar.set_points(value)


func _on_Player_health_changed(value):
	$HUD/LifeBar.set_lives(value)


func _on_Player_player_ammo_changed(value):
	$HUD/AmmoBar.set_ammo(value)


func _on_Cage_cage_idle_interaction():
	$banner_low/cage_text.set_text(cage_idle_text)
	$banner_low/cage_text.show_banner(true)


func _on_Cage_cage_keysfound_interaction():
	$banner_low/cage_text.set_text(cage_keys_text)
	$banner_low/cage_text.show_banner(true)


func _on_Cage_tiger_rescued_by_player():
	$banner_low/cage_text.set_text(tiger_rescued_text)
	$banner_low/cage_text.show_banner(true)


func _on_Cage_tiger_free() -> void:
	$banner_low/cage_text.set_text(tiger_rescued_text)
	$banner_low/cage_text.show_banner(false)
