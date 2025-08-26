extends AudioStreamPlayer2D
class_name SoundManager

@export var move_: AudioStream
@export var eat_: AudioStream
@export var winSounds: Array[AudioStream]
@export var lose_: AudioStream


func move() -> void:
	stream = move_
	play()

func eat() -> void:
	stream = eat_
	play()

func win() -> void:
	stream = winSounds[randi() % winSounds.size()]
	play()

func lose() -> void:
	stream = lose_
	play()
