extends RigidBody2D

@export var force = 1000

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("right"):
		apply_force(Vector2(force, 0))
	if Input.is_action_pressed("left"):
		apply_force(Vector2(-force, 0))
	if Input.is_action_pressed("up"):
		apply_force(Vector2(0, -force))
	if Input.is_action_pressed("down"):
		apply_force(Vector2(0, force))
