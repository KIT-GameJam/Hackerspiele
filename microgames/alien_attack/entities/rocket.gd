extends Area2D

@export var speed = 600

func _physics_process(delta):
	global_position.x += speed * delta

func _on_enemy_entered(enemy: AlienAttackEnemy):
	enemy.die()
	die()

func die():
	queue_free()

func _on_screen_exited():
	die()

func _on_timer_timeout() -> void:
	die()
