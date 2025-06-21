extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer

func _on_timer_timeout() -> void:
	anim.play("clap")
	$Timer.start(randf_range(0.2, 2.0))
