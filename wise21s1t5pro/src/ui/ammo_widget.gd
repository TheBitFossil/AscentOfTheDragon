extends TextureRect


export (SpriteFrames) var frames


func set_ammo(index):
	texture = frames.get_frame("default", index)


func _ready():
	set_ammo(0)
