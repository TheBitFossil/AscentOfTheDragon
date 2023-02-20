extends Spatial

onready var bullet_container = $bullet_container
onready var enemy_container = $enemy_container
onready var shards_container = $shards_container

onready var player = $Player
onready var player_health = $Player/health_component
onready var hud = $HUD

# Levels
onready var game_over_scene = preload("res://src/level/game/level_main_menu.tscn")
onready var outro_scn = preload("res://src/level/game/outro_video.tscn")

# Checkpoints
onready var checkpoints = $checkpoints
onready var player_respawn_pos = null
export var health_loss_on_death = 1.0

# Score, Keys Unlocks
onready var keys = $keys
export var key_fragments_needed_for_tiger_cage = 4
var key_fragments = 0
var score = 0

# Hud
onready var hud_text = $HUD/banner_low/cage_text

# Sounds
onready var audioplayer_effects = $AudioStreamPlayer_Effects
onready var audioplayer_theme = $AudioStreamPlayer_Theme

onready var respawn_sfx = preload("res://src/audio/respawn.wav")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	connect_enemy_signals()
	connect_keyspawner_signals()
	
	player_respawn_pos =  checkpoints.get_child(0).global_transform
	
	player.start(player_respawn_pos, true)
	player.add_bullet(5)
	
	$checkpoints/portal.set_active(false)
	audioplayer_theme.play()


func connect_enemy_signals():
	for child in enemy_container.get_children():
		child.connect("loot_dropped", self, "_on_Enemy_dropping_loot" )
		child.connect("enemy_fired", self, "_on_Enemy_fired")


func connect_keyspawner_signals():
	for child in keys.get_children():
		child.connect("key_spawned", self, "_on_Spawner_key_spawned")


func place_keyfragments():
	if score >= 5 and score < 10:
		keys.get_child(0).spawn_keyfragment()
	elif score >= 10 and score < 15:
		keys.get_child(1).spawn_keyfragment()
	elif score >= 15 and score < 20:
		keys.get_child(2).spawn_keyfragment()
	elif score >= 20:
		keys.get_child(3).spawn_keyfragment()


func show_banner_found_keys():
		hud_text.set_text("You have [b][color=#733272] %s shards [/color][/b] collected! A [b][color=#733272] Key [/color][/b] has spawned" % score)
		hud_text.show_banner(true)


func cheats():
	if Input.is_action_just_pressed("add_score"):
		score += 1
		$props/cage.set_child_emission(score)
		$HUD._on_Player_shard_picked_up(score)
	if Input.is_action_just_pressed("add_keys"):
		hud_text.set_text("All %s of %s fragments collected! The [b][color=#733272]cage[/color][/b] is now ready to be opnened!" % [key_fragments, key_fragments])
		hud_text.show_banner(true)
		$props/cage.set_cage_keysfound(true)


func game_over():
	get_tree().change_scene_to(game_over_scene)


func outro_scene():
	get_tree().change_scene_to(outro_scn)


func _process(_delta):
	place_keyfragments()
	#cheats()


func _on_Player_player_bullet_fired(object):
	bullet_container.add_child(object)


func _on_Player_player_died(location):
	game_over()


func _on_Enemy_dropping_loot(item):
	shards_container.add_child(item)
	item.connect("picked_up", self, "_on_shard_gathered")


func _on_Enemy_fired(object):
	bullet_container.add_child(object)


func _on_shard_gathered(value):
	score += value
	$HUD._on_Player_shard_picked_up(score)
	$props/cage.set_child_emission(score)


func _on_death_unlocking_player_jump():
	player.unlock_jump(true)


func _on_Booster_picked_up(is_double_jump_boost : bool, double_jump_time : float):
	if is_double_jump_boost:
		player.start_double_jump_boost_timer(double_jump_time)
		player.unlock_double_jump(true)


func _on_Player_picked_up_key(amount):
	key_fragments += amount
	hud_text.set_text("Picked up Keyfragment! We now have [b][color=#733272] %s keyfragments[/color][/b] collected!" % key_fragments)
	hud_text.show_banner(true)
	
	if key_fragments >= key_fragments_needed_for_tiger_cage:
		hud_text.set_text("All %s of %s fragments collected! The [b][color=#733272]cage[/color][/b] is now ready to be opnened!" % [key_fragments, key_fragments])
		hud_text.show_banner(true)
		$props/cage.set_cage_keysfound(true)


func _on_OutOfBoundsCollector_garbage_collected(object):
	if object.has_method("reset_position"):
		object.reset_position(player_respawn_pos)
		audioplayer_effects.stream = respawn_sfx
		audioplayer_effects.play()
		
		for child in object.get_children():
			if child.has_method("subtract_health"):
				child.subtract_health(health_loss_on_death)
				
		if object.has_method("reset_bullets"):
			object.reset_bullets()
			
	elif object.has_method("reset_position") and object.is_alive == false:
		game_over()


func _on_Checkpoint_new_spawn_location(location):
	player_respawn_pos = location


func _on_Spawner_key_spawned(item):
	keys.add_child(item)
	item.connect("picked_up_key", self, "_on_Player_picked_up_key")
	show_banner_found_keys()


func _on_portal_player_reached_end() -> void:
	outro_scene()


func _on_cage_tiger_rescued_by_player() -> void:
	$checkpoints/portal.set_active(true)
