extends RigidBody2D

@export var force = 1000
var reset_vel := false

func _physics_process(_delta: float) -> void:
	# eleminate diff by resetting twice
	if reset_vel:
		reset()
		reset_vel = false
	
	if Input.is_action_pressed("right"):
		apply_force(Vector2(force, 0))
	if Input.is_action_pressed("left"):
		apply_force(Vector2(-force, 0))
	if Input.is_action_pressed("up"):
		apply_force(Vector2(0, -force))
	if Input.is_action_pressed("down"):
		apply_force(Vector2(0, force))

func reset():
	global_position = Vector2()
	linear_velocity = Vector2()
	set_axis_velocity(Vector2())
	apply_force(Vector2())
	reset_vel = true
