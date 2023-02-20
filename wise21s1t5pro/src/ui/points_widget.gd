extends TextureRect


export (SpriteFrames) var frames


func _ready():
	set_points(0)


func set_points(index):
	texture = frames.get_frame("default", index)
