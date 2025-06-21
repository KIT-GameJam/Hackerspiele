extends MicroGame

const Ufo = preload("res://microgames/jeff_encounter/entities/Ufo.tscn")

@export var UFO_SPAWN_CHANCE = 0.5

func on_timeout():
	return Result.Win

func _on_ufo_timer_timeout():
	if randf_range(0, 1) <= UFO_SPAWN_CHANCE:
		add_child(Ufo.instantiate())


func _on_jeff_was_hit() -> void:
	finished.emit(Result.Loss)
