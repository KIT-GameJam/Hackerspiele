class_name SkyObstacle
extends RigidBody2D

func _ready() -> void:
	pass
	#connect("body_entered", _on_body_entered)
	#print(contact_monitor)
	#print(max_contacts_reported)

func set_height(height: float):
	$Mesh.scale.y = height
	$CollisionBox.scale.y = height
	$Area2D/CollisionArea.scale.y = height
	
func _on_body_entered(body: Node) -> void:
	# Does not work for character bodys :(
	if body is not PlayerBody:
		return
	#print_debug("collision with player")
	body.register_hit_by_obstacle(self)
