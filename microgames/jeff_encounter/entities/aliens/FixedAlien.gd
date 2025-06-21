extends CharacterBody2D

const Bullet = preload("res://microgames/jeff_encounter/entities/bullets/LineBullet.tscn")
const BULLET_SPEED: float = 1.5

var shooting_direction := Vector2(1, 0) * BULLET_SPEED
var counter1 := 0
var counter2 := 0

func _on_timer_timeout():
	counter1 += 1
	counter2 += 1
	if counter1 == 4:
		counter1 = 0
		return
	if counter2 == 9:
		counter2 = 0
		return
	var bullet = Bullet.instantiate()
	bullet.direction = shooting_direction
	bullet.rotation = bullet.direction.angle() - PI/2
	bullet.position = position
	if counter2 != 3:
		var bullet2 = Bullet.instantiate()
		bullet2.direction = -shooting_direction
		bullet2.rotation = bullet2.direction.angle() - PI/2
		bullet2.position = position
		get_parent().add_child(bullet2)
	shooting_direction = shooting_direction.orthogonal()
	get_parent().add_child(bullet)
