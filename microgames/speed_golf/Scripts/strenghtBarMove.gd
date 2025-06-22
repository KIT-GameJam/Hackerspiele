extends Node2D

func _process(_delta: float) -> void:
	var currentStrenght = get_parent().get_parent().strokeStrength
	position.x = -20 - currentStrenght * 10
