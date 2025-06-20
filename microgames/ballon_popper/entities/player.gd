extends Node3D

const projectile_scene := preload("res://microgames/ballon_popper/entities/pojectile.tscn")

@export var tilt_speed = 2
@export var shoot_impuls = 20
@onready var body := $Body
@onready var projectile_container := $Projectiles
@onready var cannon_led := $Body/Led
@onready var cannon_laser := $Body/Laser

func _physics_process(delta: float) -> void:
	var tilt_input = Input.get_vector("right", "left", "down", "up")
	if not tilt_input.is_zero_approx():
		var tilt_dir = Vector3(tilt_input.y, tilt_input.x, 0.0).normalized()
		body.rotate(tilt_dir.normalized(), tilt_speed * delta)
		_keep_rotation_in_bounce()
	
	if Input.is_action_just_pressed("submit"):
		shoot()

func shoot():
	var shoot_dir = cannon_led.global_position.direction_to(cannon_laser.global_position)
	var projectile := projectile_scene.instantiate()
	projectile_container.add_child(projectile)
	projectile.global_position = cannon_led.global_position
	projectile.apply_impulse(shoot_dir * shoot_impuls)

func _keep_rotation_in_bounce():
	pass
	#if body.rotation_degrees.x < -20.0:
		#body.rotation_degrees.x = -20.0
	#if body.rotation_degrees.x > 20.0:
		#body.rotation_degrees.x = 20.0
	#if body.rotation_degrees.y < -20.0:
		#body.rotation_degrees.y = -20.0
	#if body.rotation_degrees.y > 20.0:
		#body.rotation_degrees.y = 20.0
