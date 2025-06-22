extends Sprite2D

func _process(_delta: float) -> void:
	var currentStrenght = get_parent().get_parent().get_parent().strokeStrength
	region_rect.position.y = 19 * (1-currentStrenght)
	scale.y = (currentStrenght)
