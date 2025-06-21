extends AlienAttackAlien

func _ready() -> void:
	Bullet = preload("res://microgames/jeff_encounter/entities/bullets/HomingBullet.tscn")

func _on_timer_timeout():
	spawn_bullet(randf_range(0, 2.0 * PI))
