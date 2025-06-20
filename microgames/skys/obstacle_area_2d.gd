extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is not PlayerBody:
		return
	#print_debug("collision with player")
	(body as PlayerBody).register_hit_by_obstacle(self)
