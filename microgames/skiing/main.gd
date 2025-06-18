extends MicroGame

func _on_goal_player_entered(player: Player) -> void:
	finished.emit(Result.Win)
