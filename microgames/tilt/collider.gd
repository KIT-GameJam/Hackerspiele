extends StaticBody2D

func _process(delta: float) -> void:
	var tween = get_tree().create_tween()
	var rotation_strength = Input.get_axis("left", "right")
	tween.tween_property(self, "rotation_degrees", 20 * rotation_strength, .5)
	#self.rotation_degrees = 20 * rotation_strength
