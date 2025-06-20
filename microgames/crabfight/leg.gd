extends Node2D

@onready var player: AnimationPlayer = $AnimationPlayer

func toggle_dir() -> void:
	player.speed_scale *= -1.0

func set_playing(val: bool):
	if not player.is_playing() and val:
		player.play("walk")
	elif not val and player.is_playing():
		player.stop()
