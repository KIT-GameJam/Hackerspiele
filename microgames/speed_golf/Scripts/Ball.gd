extends RigidBody2D

@export var rotationSpeed = 5
var strokeStrength = 0
var lastStrokeStrength = 0
var pressedDown = false
var strenghtGrow = 3

func _process(delta: float) -> void:
	if Input.is_action_pressed("right"):
		$DrehObjekt.rotate(rotationSpeed * delta)
	elif Input.is_action_pressed("left"):
		$DrehObjekt.rotate(-1 * rotationSpeed * delta)

	if pressedDown && Input.is_action_pressed("submit"):
		strokeStrength = min(strokeStrength + strenghtGrow *delta, 1)
	elif Input.is_action_pressed("submit"):
		pressedDown = true
	else:
		if strokeStrength != 0:
			lastStrokeStrength = strokeStrength
		pressedDown = false
		strokeStrength = 0

	if Input.is_action_just_released("submit"):
		var impulseVector = Vector2(cos($DrehObjekt.rotation), sin($DrehObjekt.rotation))
		if get_parent().cellId == 2:
			self.apply_central_impulse(pow(lastStrokeStrength, 2.5) * 300 * impulseVector)
		elif get_parent().cellId == 3:
			self.apply_central_impulse(pow(lastStrokeStrength, 2.5) * 100 * impulseVector)
