extends MicroGame

func _ready() -> void:
	finished.emit(Result.Win)
