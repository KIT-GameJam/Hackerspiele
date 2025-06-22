extends Node2D

const MARGIN := Vector2(10, 10)
const SPEED: float = 200
const BULLET_SPEED: float = 1
const MAX_TRAVEL_TIME := 1000

const Bullet = preload("res://microgames/jeff_encounter/entities/bullets/PointBullet.tscn")

var direction: Vector2
var travel_time := 0

func _ready():
	var viewport := get_viewport()
	var cam := viewport.get_camera_2d()
	var vps := viewport.get_visible_rect().size / cam.zoom
	var vp: Rect2 = Rect2(cam.position - vps * 0.5, vps)

	# generate random path
	var edges: Array[int] = [0, 1, 2, 3]
	var start_edge = sample(edges)
	position = rand_edge_point(vp, start_edge)
	edges.erase(start_edge)
	var end_edge = sample(edges)
	direction = position.direction_to(rand_edge_point(vp, end_edge))

func _physics_process(_delta):
	var region: Rect2 = $Sprite2D.get_rect()
	region.position += position

func sample(elements: Array):
	var idx := randi_range(0, elements.size() - 1)
	return elements[idx]

func rand_edge_point(vp: Rect2, edge: int) -> Vector2:
	var rand := randf_range(0, 1)
	var coord := rand * vp.size

	if edge == 0:
		coord.x = -MARGIN.x
	elif edge == 1:
		coord.x = vp.size.x + MARGIN.x
	elif edge == 2:
		coord.y = -MARGIN.y
	elif edge == 3:
		coord.y = vp.size.y + MARGIN.y

	return coord + vp.position

func _on_timer_timeout():
	for alpha in [1, -1]:
		var bullet = Bullet.instantiate()

		bullet.direction = direction.rotated(alpha) * BULLET_SPEED
		bullet.position = position

		get_parent().add_child(bullet)
