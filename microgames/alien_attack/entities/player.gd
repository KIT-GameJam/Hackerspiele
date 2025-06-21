class_name AlienAttackPlayer extends CharacterBody2D

@export var speed := 600
@onready var rocket_container := $RocketContainer
@onready var rocket_shot_sound := $RocketShotSound

const rocket_scene := preload("res://microgames/alien_attack/entities/rocket.tscn")
const shoot_offset := Vector2(60, 0)

signal took_damage

func _physics_process(_delta):
	velocity = Input.get_vector("left", "right", "up", "down") * speed
	move_and_slide()

	var viewport_size := get_viewport_rect().size
	global_position = global_position.clamp(Vector2(0, 0), viewport_size)

func _process(_delta):
	if Input.is_action_just_pressed("submit"):
		shoot()

func shoot():
	var rocket := rocket_scene.instantiate()
	rocket.global_position = global_position + shoot_offset
	rocket_container.add_child(rocket)
	rocket_shot_sound.play()

func die():
	queue_free()

func take_damage():
	emit_signal("took_damage")
