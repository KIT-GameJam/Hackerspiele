extends RigidBody2D
class_name TiltBall

@export
var type: int = 0;

func _ready() -> void:
	var horizontal_position: float = 640 + randf_range(-0.3, 0.3)
	position = Vector2(horizontal_position, -10)
	var gravitiy: Vector2 = Vector2(0, 1)
	self.add_constant_central_force(gravitiy)
	type = randi_range(0, 3)
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
	
func unparent() -> void:
	get_parent().remove_child(self)
