extends RigidBody2D

var type: int = 0;

func _ready() -> void:
	position = Vector2(640, -10)
	var gravitiy: Vector2 = Vector2(0, 1)
	self.add_constant_central_force(gravitiy)
	#var type: int = randi_range(0, 3)
	#self.modulate = Color(1, 0, 0)
	
