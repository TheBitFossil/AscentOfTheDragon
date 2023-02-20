extends StaticBody

signal player_health_changed
signal player_died

# Health
export var max_health : int = 5
var current_health : int = 0
var is_alive : bool = true
var can_be_damaged : bool = true

# Sound
export (Array, AudioStream) var hurt_sounds
export var death_sound : AudioStream
onready var audiostream_player : AudioStreamPlayer = $audio_stream_player


func _ready():
	add_health(max_health)


func subtract_health(val):
	if current_health - val > 0:
		current_health -= val
		play_sound(current_health)
		emit_signal("player_health_changed", current_health)
	elif current_health - val <= 0:
		current_health = 0
		play_sound(current_health)
		emit_signal("player_health_changed", current_health)


func add_health(val):
	if current_health + val < max_health:
		current_health += val
	elif current_health + val >= max_health:
		current_health = max_health
		
	emit_signal("player_health_changed", current_health)


func play_sound(_hp):
	match _hp:
		4:
			audiostream_player.stream = hurt_sounds[0]
		3:
			audiostream_player.stream = hurt_sounds[0]
		2:
			audiostream_player.stream = hurt_sounds[1]
		1:
			audiostream_player.stream = hurt_sounds[2]
		0:
			audiostream_player.stream = death_sound
			audiostream_player.play()
			emit_signal("player_died")
			
	audiostream_player.play()
