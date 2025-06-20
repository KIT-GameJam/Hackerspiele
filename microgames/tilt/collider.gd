extends CollisionShape2D

func _process(delta: float) -> void:
	var rotation_strength = Input.get_axis("left", "right")
	self.rotation_degrees = 20 * rotation_strength
