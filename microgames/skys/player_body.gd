extends CharacterBody2D

func _physics_process(delta: float) -> void:
	# Constants:
	var base_speed = 10.;
	# idea: store up jump "force/energy" by pressing down and apply accel when button released
	var jump_acceleration = 20; # m/s²
	var gravity = 9.8; # m/s^2
	var floor_level = 0; # y coordinate of floor
	# stuff:
	var accelarion = Vector2(0, 0)
	
	var updown_dir = Input.get_axis("down", "up")
	accelarion += up_direction * updown_dir * jump_acceleration
	if position.y < 0:
		# in air
		accelarion += up_direction * -gravity
	else:
		# On or below ground
		# cancel upwards motion, needlessly complex...
		velocity -= up_direction * velocity.dot(up_direction)
		#velocity.y = 0
		pass
	
	velocity.x = base_speed
	velocity += accelarion * delta # integrate accelarations
	#velocity.x = base_speed * lr_dir
	
	move_and_slide()
	#velocity.y = 2
