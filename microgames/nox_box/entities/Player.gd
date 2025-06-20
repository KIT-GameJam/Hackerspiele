extends RigidBody2D

@export var hit_force := 50.0

func _process(delta):
	var dir = Input.get_vector("left", "right", "up", "down")
	apply_impulse(dir * hit_force)
