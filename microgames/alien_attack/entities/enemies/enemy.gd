class_name AlienAttackEnemy extends Area2D

@export var speed = 300
signal died

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	global_position.x -= speed * delta

func die():
	emit_signal("died")
	queue_free()

func _on_player_entered(player: AlienAttackPlayer):
	player.take_damage()
	die()
