extends MicroGame

func _ready() -> void:
	finished.emit(Result.Win)


func _on_killzone_entered(body: Node2D) -> void:
	print("ded")
	finished.emit(Result.Loss)
 # Replace with function body.
