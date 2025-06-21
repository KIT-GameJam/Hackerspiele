class_name Trap extends Node2D

signal touched_player(player: MartianMikePlayer)

func _on_hitbox_player_entered(player: MartianMikePlayer):
	touched_player.emit(player)
