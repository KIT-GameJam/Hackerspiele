class_name EverestPlayer extends CharacterBody2D
var side_speed = 5000
var dash_speed_side = 16000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dash_ready = 0
var grav_off = 0


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("submit"):
		if dash_ready == 0:
			dash_ready = 0.12
			if Input.is_action_pressed("right"):
				velocity.x = dash_speed_side * delta
			else:
				velocity.x = velocity.x/1.1
			if Input.is_action_pressed("left"):
				velocity.x = -dash_speed_side * delta
			else:
				velocity.x = velocity.x/1.1
			if Input.is_action_pressed("up"):
				velocity.y = -25000 * delta
			else:
				grav_off = 0.3
				if velocity.y > 0:
					velocity.y = 0
	else:
		if Input.is_action_pressed("up") && is_on_floor():
			velocity.y = -22000 * delta
		if Input.is_action_pressed("left"):
			if velocity.x > -side_speed * delta:
				velocity.x = -side_speed * delta
		else:
			velocity.x = velocity.x/1.1
		if Input.is_action_pressed("right"):
			if velocity.x < side_speed * delta:	
				velocity.x = side_speed * delta
		else:
			velocity.x = velocity.x/1.1
		
	
	if is_on_floor():
		if dash_ready > 0:
			dash_ready -= delta
		if dash_ready < 0:
			dash_ready = 0
	
	if not is_on_floor() && grav_off == 0:
		velocity.y += gravity * delta
	
	if grav_off > 0:
		grav_off -= delta
		if grav_off < 0:
			grav_off = 0
	
	move_and_slide()
	
	
