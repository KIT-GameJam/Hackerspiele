class_name AlienAttackBullet extends CharacterBody2D

@export var speed := 30.0

var direction: Vector2

func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()

func _on_player_hit(area):
	# hit player and despawn
	area.get_parent().hit_player(direction)
	queue_free()

func _on_building_collision(_body):
	# despawn
	queue_free()
