tool
extends Button

signal start_scene_change


export (String, FILE) var scene_to_load = ""


func get_configuration_warning():
	if scene_to_load == "":
		print ("Scene to load must be set before use !")
	else: 
		return ""


func _on_button_up():
	get_tree().change_scene(scene_to_load)
	#emit_signal("start_scene_change", scene_to_load)
