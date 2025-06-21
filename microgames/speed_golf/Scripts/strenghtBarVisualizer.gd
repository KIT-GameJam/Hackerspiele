extends Sprite2D
var pressedDown = false
var currentStrenght = 0
var strenghtGrow = 3

func _process(delta: float) -> void:
	if pressedDown && Input.is_action_pressed("submit"):
		currentStrenght = min(currentStrenght + strenghtGrow *delta, 1)
	elif Input.is_action_pressed("submit"):
		pressedDown = true
	else:
		pressedDown = false
		currentStrenght = 0
	
	#region_rect.size.y = 19 * (1- currentStrenght)
	region_rect.position.y = 19 * (1-currentStrenght)
	scale.y = (currentStrenght)
