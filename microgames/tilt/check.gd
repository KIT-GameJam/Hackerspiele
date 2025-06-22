extends Area2D
class_name TiltGoalArea


func _on_body_entered(body: TiltBall) -> void:
	if (body.type != get_meta("type")):
		get_parent().end()

	get_parent().ball_finished()
	body.unparent()
