extends MicroGame

@onready var num_ballons: int = $Ballons.get_children(false).size()

func _on_ballon_popped() -> void:
	num_ballons -= 1
	if num_ballons == 0:
		finished.emit(Result.Win)
