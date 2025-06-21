class_name AlienAttackAlien extends CharacterBody2D

@export var MOVEMENT_SPEED = 15
@export var MIN_MOVEMENT_RADIUS := 3
@export var MAX_MOVEMENT_RADIUS := 8
@export var WALK_CHANCE := 0.2

# const Bullet = preload("res://scenes/bullets/PointBullet.tscn")
var Bullet

@onready var anim_player: AnimationPlayer = get_node('WalkAnimationPlayer') if has_node('WalkAnimationPlayer') else null

func spawn_bullet(rot_angle: float) -> void:
	var bullet = Bullet.instantiate()
	bullet.direction = Vector2.from_angle(rot_angle)
	bullet.rotation = rot_angle - PI/2
	bullet.position = position
	get_parent().add_child(bullet)
