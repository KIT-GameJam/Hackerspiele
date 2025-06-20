extends Area2D

func _on_body_entered(_player):
	queue_free()

func _ready():
	var animatedSprite2D: AnimatedSprite2D = $Sprite2D
	animatedSprite2D.play()
