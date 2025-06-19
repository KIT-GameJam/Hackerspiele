class_name Maze extends Node2D

signal win
signal loss

func _on_level_player_exited(_body: Node2D) -> void:
	loss.emit()


func _on_win_zone_player_entered(_body: Node2D) -> void:
	win.emit()
