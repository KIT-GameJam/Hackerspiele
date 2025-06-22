extends MicroGame

func _ready() -> void:
	# Load random level
	var level = load("res://microgames/toast/levels/level_" + str(randi_range(1, 3)) + ".tscn")
	var level_instance = level.instantiate()
	$"[INTERFACE]Obstacles".add_child(level_instance)

	$AnimationPlayer.play("intro")

func _win():
	$SpeechBubble/SpeechBubbleLabel.text = "[tornado radius=5.0 freq=10.0 connected=1]OMG, THANKS! [color=red]❤️[/color][/tornado]"
	$AnimationPlayer.play("outro_win")
	await $AnimationPlayer.animation_finished
	finished.emit(Result.Win)

func _lose():
	$SpeechBubble/SpeechBubbleLabel.text = "[shake rate=40.0 level=80 connected=1][b]FUCK YOU.[/b][/shake]"
	$AnimationPlayer.play("outro_win")
	await $AnimationPlayer.animation_finished
	finished.emit(Result.Loss)
