extends Node2D

@export var base_speed = 100.0
@export var boost_multiplier = 1000.0
@export var acceleration_rate = 100
@export var deceleration_rate = 100

var current_speed = 0.0
var previous_direction = Vector2.ZERO

func _physics_process(delta):
	position += previous_direction * current_speed * delta
	# Get input from WASD keys
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1

	# Normalize direction vector
	if direction.length() > 0:
		direction = direction.normalized()

	# Handle velocity changes
	if direction != Vector2.ZERO:
		if direction == previous_direction:
			# Increase speed while holding same direction
			current_speed = current_speed + acceleration_rate
		else:
			# Reset speed when changing direction
			current_speed = max(0, current_speed - deceleration_rate)
	else:
		# Gradually decrease speed when no input
		current_speed = max(0, current_speed - deceleration_rate)

	# Store current direction for next frame comparison
	previous_direction = direction

	# Apply movement


