extends Camera

export var min_zoom := 55.0
export var max_zoom := 65.0

export var zoom_factor := 5.0
export var zoom_duration := .1

onready var tween = $Tween

var _zoom_level := 55.0 setget _set_zoom_level


func _set_zoom_level(value : float):
	_zoom_level = clamp(value, min_zoom, max_zoom)
	
	tween.interpolate_property(self,
		"fov",
		get_fov(),
		_zoom_level,
		zoom_duration,
		tween.TRANS_SINE,
		tween.EASE_OUT
	)
	tween.start()


func _unhandled_input(event):
	if event.get_action_strength("zoom_in"):
		self._set_zoom_level(_zoom_level - zoom_factor)
		#print("z-")
	if event.get_action_strength("zoom_out"):
		self._set_zoom_level(_zoom_level + zoom_factor)
		#print("z+")
