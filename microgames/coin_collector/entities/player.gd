extends CharacterBody2D

@export var SPEED = 3600.0
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _physics_process(delta: float):
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	if (Input.is_action_pressed("right") && sprite.scale.x >= 0): sprite.scale.x *= -1
	elif (Input.is_action_pressed("left")  && sprite.scale.x <= 0): sprite.scale.x *= -1
	velocity = direction * SPEED * delta
	move_and_slide()

func on_coin_collected():
	sprite.scale *= 1.1
	collision.scale *= 1.1
