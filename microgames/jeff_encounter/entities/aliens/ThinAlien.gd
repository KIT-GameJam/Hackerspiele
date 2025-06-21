extends CharacterBody2D

@export var NUM_BULLETS := 6
var ANGLE_STEP := 2 * PI / NUM_BULLETS

const Bullet = preload("res://microgames/jeff_encounter/entities/bullets/CircleBullet.tscn")

var shooting_angle := 0.0

func _on_timer_timeout():
	var local_angle := shooting_angle
	for i in range(NUM_BULLETS):
		var bullet = Bullet.instantiate()
		bullet.direction = Vector2.from_angle(local_angle)
		bullet.rotation = local_angle - PI/2
		bullet.position = position
		get_parent().add_child(bullet)
		local_angle += ANGLE_STEP
	shooting_angle = fposmod(shooting_angle + 0.5, 2 * PI)
