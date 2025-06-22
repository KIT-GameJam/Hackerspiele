class_name SkyObstacle
extends RigidBody2D

func _ready() -> void:
	pass
	#connect("body_entered", _on_body_entered)
	#print(contact_monitor)
	#print(max_contacts_reported)
var height : float = 1.;

func set_height(height_: float):
	height = height_
	$Mesh.scale.y = height
	$CollisionBox.scale.y = height
	$Area2D/CollisionArea.scale.y = height

	#$Mesh.material.set("shader_parameter/scale", height);
	
func _on_body_entered(body: Node) -> void:
	# Does not work for character bodys :(
	if body is not PlayerBody:
		return
	#print_debug("collision with player")
	body.register_hit_by_obstacle(self)
