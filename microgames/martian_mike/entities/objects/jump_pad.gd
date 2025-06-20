extends Area2D

@export var jump_force = 600
@onready var animation_player = $AnimatedSprite2D

func _on_player_entered(player: MartianMikePlayer):
	animation_player.play("jump")
	player.jump(jump_force)
