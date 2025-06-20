extends MicroGame

func _ready() -> void:
	$AnimationPlayer.play("intro")
	
	#finished.emit(Result.Win)
