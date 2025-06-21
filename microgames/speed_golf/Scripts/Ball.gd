extends Sprite2D

@export var rotationSpeed = 5

func _process(delta: float) -> void:
	if Input.is_action_pressed("right"):
		rotate(rotationSpeed * delta)
	elif Input.is_action_pressed("left"):
		rotate(-1 * rotationSpeed * delta)
