extends MicroGame

func _ready() -> void:
	$AnimationPlayer.play("intro")

func _win():
	$SpeechBubble/SpeechBubbleLabel.text = "[shake rate=20.0 level=35 connected=1]OMG, THANKS! [color=red]❤️[/color][/shake]"
	$AnimationPlayer.play("outro_win")
	await $AnimationPlayer.animation_finished
	finished.emit(Result.Win)
