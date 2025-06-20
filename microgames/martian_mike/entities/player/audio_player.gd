class_name MartianMikeAudioPlayer extends Node

var hurt := preload("res://microgames/martian_mike/assets/audio/hurt.wav")
var jump := preload("res://microgames/martian_mike/assets/audio/jump.wav")

func play_sfx(sfx_name: String):
	var stream: AudioStream = null
	if sfx_name == "hurt":
		stream = hurt
	elif sfx_name == "jump":
		stream = jump
	else:
		print("Invalid sfx name")
		return

	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	asp.name = "SFX_" + sfx_name
	add_child(asp)
	asp.play()
	await asp.finished
	asp.queue_free()
