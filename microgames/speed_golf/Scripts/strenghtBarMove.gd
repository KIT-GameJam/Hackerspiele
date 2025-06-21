extends Node2D

func _process(delta: float) -> void:
	var currentStrenght = get_parent().get_parent().strokeStrength
	position.x = -20 - currentStrenght * 10
