extends RigidBody2D

func _physics_process(delta: float) -> void:
	var gravitiy: Vector2 = Vector2(0, 1)
	self.add_constant_central_force(gravitiy)
