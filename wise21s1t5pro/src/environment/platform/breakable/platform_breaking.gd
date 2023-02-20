extends Spatial


export var is_breakable : bool = false
export var react_to_player : bool = false
export var react_to_enemy : bool = false
export var can_respawn : bool = false 

export var platform_template = preload("res://src/environment/platform/breakable/platform_breaking_moss_single.tscn")


func _ready() -> void:
	if is_breakable:
		for child in get_children():
			if child.has_method("react_to"):
				child.react_to(react_to_player, react_to_enemy, can_respawn)


func _on_platform_breaking_moss_create_new(position : Vector3) -> void:
	var template = platform_template.instance()
	template.set_translation(position)
	template.react_to(react_to_player, react_to_enemy, can_respawn)
	
	add_child(template)
	#print("Adding new Platform child at:", template.global_transform.origin)


func _on_platform_breaking_moss_3_broken() -> void:
	queue_free()
