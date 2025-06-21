extends Node3D

@export var wiggle_angle_deg: float = 15.0
@export var wiggle_offset: float = 0.5
@export var wiggle_duration: float = 0.25

var base_rotation: Vector3
var base_position: Vector3

func _ready() -> void:
	base_rotation = rotation
	base_position = position

	var tween = create_tween()
	tween.set_loops()

	var angle_rad = deg_to_rad(wiggle_angle_deg)
	tween.tween_property(self, "rotation:y", base_rotation.y + angle_rad, wiggle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "position:x", base_position.x + wiggle_offset, wiggle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation:y", base_rotation.y - angle_rad, wiggle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "position:x", base_position.x - wiggle_offset, wiggle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
