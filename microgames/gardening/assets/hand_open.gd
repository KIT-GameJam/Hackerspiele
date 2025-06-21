extends Node3D

func _ready() -> void:
	var tween = create_tween()
	var original_pos = global_position
	tween.tween_property(self, "global_position:y", original_pos.y + 2.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position:y", original_pos.y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
