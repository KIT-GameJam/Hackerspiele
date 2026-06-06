extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is EverestPlayer:
		get_parent().finished.emit(MicroGame.Result.Win)
		print("Win")
