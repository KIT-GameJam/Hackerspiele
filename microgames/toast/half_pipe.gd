@tool
extends Node2D

@export var line_node: NodePath
@export var collision_polygon_node: NodePath
@export var line_width: float = 10.0

func _ready():
	generate_collision_from_line()

func generate_collision_from_line():
	var line = get_node_or_null(line_node) as Line2D
	var collision_polygon = get_node_or_null(collision_polygon_node) as CollisionPolygon2D

	if not line or not collision_polygon:
		print("Line2D or CollisionPolygon2D node not found.")
		return

	var line_points = line.points
	if line_points.size() < 2:
		print("Line2D needs at least 2 points to generate a collision shape.")
		return

	for i in range(0, line_points.size()):
		line_points[i] += line.position
	# Use Geometry2D.offset_polyline to create a polygon with thickness
	var polygon_points = Geometry2D.offset_polyline(
		line_points,
		line_width / 2.0,
		Geometry2D.JOIN_SQUARE,
		Geometry2D.END_ROUND
	)

	if not polygon_points.is_empty():
		collision_polygon.polygon = polygon_points[0]
	else:
		print("Failed to generate polygon points.")
