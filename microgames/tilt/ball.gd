extends RigidBody2D

func _ready() -> void:
	position = Vector2(640, -10)
	var gravitiy: Vector2 = Vector2(0, 1)
	self.add_constant_central_force(gravitiy)
	var type: int = randi_range(0, 3)
	var color = Color(0, 0, 0)
	match type:
		0:
			color = Color(1, 0, 0)
		1:
			color = Color(0, 1, 0)
		2:
			color = Color(0, 0, 1)
		3:
			color = Color(1, 0, 1)
	self.modulate = color
	
