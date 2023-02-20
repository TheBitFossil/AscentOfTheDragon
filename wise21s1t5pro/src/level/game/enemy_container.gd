extends Spatial



func connect_enemy_signals():
	var root_node = get_parent()
	
	for child in get_children():
		child.connect("dropping_loot", root_node, "_on_Enemy_dropping_loot" )
		child.connect("enemy_bullet_fired", root_node, "_on_Enemy_bullet_fired")
