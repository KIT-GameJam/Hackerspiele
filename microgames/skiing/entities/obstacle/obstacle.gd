class_name Obstacle
extends Area3D

@export var obstacle_type: OBSTACLE_TYPE

enum OBSTACLE_TYPE {TREE, BUSH, BOOST}

var flow_factor: float = 1

func _ready() -> void:
	match obstacle_type:
		OBSTACLE_TYPE.TREE:
			flow_factor = 0.5
		OBSTACLE_TYPE.BUSH:
			flow_factor = 0.7
		OBSTACLE_TYPE.BOOST:
			flow_factor = 1.5

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		(body as Player).change_flow_factor(flow_factor)
	else:
		printerr("Something that is not a Player has entered the Obstacle.")
