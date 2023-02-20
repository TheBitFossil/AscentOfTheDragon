extends TextureRect

export (SpriteFrames) var frames


func _ready():
	set_lives(0)


func set_lives(index):
	texture = frames.get_frame("default", index)
