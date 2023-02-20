extends Spatial


signal cage_idle_interaction()
signal cage_keysfound_interaction()
signal tiger_rescued_by_player()
signal tiger_free()


enum {IDLE, OPEN, KEYSFOUND}
var state = null

export var is_door_closed = true
export var is_unlocked = false
export var lever_used = false
export var tiger_free = false

onready var anim_cage = $cage/animation_player
onready var anim_lever = $cage_button/lever/animation_player

var is_lever_interactable = false

var normal_material = preload("res://assets/models3d/cage/textures_crystals.material")
var emission_material = preload("res://src/materials/crystal_material_emission.res")


func _ready():
	set_state(IDLE)
	reset_child_material()


func set_state(_state):
	match _state:
		IDLE:
			is_door_closed = true
			lever_used = false
			tiger_free = false
			is_unlocked = false
		KEYSFOUND:
			is_door_closed = false
			tiger_free = false
			is_unlocked = true
		OPEN:
			tiger_free = true
			is_unlocked = true
	state = _state


func _input(_event):
	if not is_lever_interactable:
		return
		
	if Input.is_action_pressed("action_interact") and not tiger_free:
		if state == IDLE:
			anim_lever.play("CHANGE")
			emit_signal("cage_idle_interaction")
		elif state == KEYSFOUND:
			anim_lever.play("CHANGE")
			emit_signal("cage_keysfound_interaction")
		else:
			#print("Cage state", state)
			pass

func reset_child_material():
	for child in $cage/crystal.get_children():
		child.set_surface_material(0, normal_material)


func set_child_emission(index: int):
	if index <= $cage/crystal.get_child_count():
		for i in range(0, index):
			$cage/crystal.get_child(i).set_surface_material(0, emission_material)


func set_cage_keysfound(value : bool):
	if value:
		set_state(KEYSFOUND)


func toggle_door():
	$AudioStreamPlayer.play()
	$Sprite3D/animation_player.play("walk")
	emit_signal("tiger_rescued_by_player")
	anim_cage.play("bars_opening")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "CHANGE":
		if state == KEYSFOUND:
			toggle_door()
			set_state(OPEN)
			emit_signal("tiger_free")


func _on_cage_button_body_entered(body: Node) -> void:
	if body.has_method("collect_item") and not tiger_free:
		is_lever_interactable = true


func _on_cage_button_body_exited(body: Node) -> void:
	if body.has_method("collect_item"):
		is_lever_interactable = false
