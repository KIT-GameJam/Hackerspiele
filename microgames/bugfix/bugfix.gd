extends MicroGame

const LEG_MOVEMENT_SPEED := 20.0
const LEG_MOVEMENT_SIZE := Vector2(5.0, 20.0)
const MIN_DIST := 80.0

@export var hammer_speed := 400.0
@export var bug_speed := 600.0

@onready var hammer: Sprite2D = $Hammer
@onready var marker: Marker2D = $Hammer/Marker2D
@onready var bug: Sprite2D = $Bug
@onready var anim: AnimationPlayer = $Hit
@onready var err: Sprite2D = $Error
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var path: Path2D
@onready var target: Vector2
@onready var legs: Array[Line2D] = [
	$Bug/Line2D,
	$Bug/Line2D2,
	$Bug/Line2D3,
	$Bug/Line2D4,
	$Bug/Line2D5,
	$Bug/Line2D6
]
@onready var leg_coords: Array[Vector2] = []
var leg_t: Array[float]

func random_point() -> Vector2:
	return Vector2(randf(), randf()) * get_viewport().get_visible_rect().size

func _ready() -> void:
	for leg in legs:
		leg_coords.append(leg.points[0])
	for i in range(6):
		leg_t.append(randf_range(0.0, PI))
	bug.global_position = random_point()

func _process(delta: float) -> void:
	for leg_idx in range(6):
		leg_t[leg_idx] += delta * LEG_MOVEMENT_SPEED * randf_range(0.9, 1.1)
		var t := leg_t[leg_idx]
		var leg: Line2D = legs[leg_idx]
		leg.points[0] = leg_coords[leg_idx] + Vector2(sin(t), cos(t)) * LEG_MOVEMENT_SIZE
	if Input.is_action_just_pressed("submit"):
		anim.play("hit")
		var dupl: Sprite2D = err.duplicate()
		dupl.visible = true
		dupl.global_position = marker.global_position
		canvas_layer.add_child(dupl)
		if marker.global_position.distance_to(bug.global_position) <= MIN_DIST:
			finished.emit(Result.Win)
	var dir := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	hammer.position += dir * delta * hammer_speed
	var d := target - bug.global_position
	var step: float = delta * bug_speed
	if step >= d.length():
		target = random_point()
	d = d.normalized()
	bug.rotation = d.angle() + PI * 0.5
	bug.global_position += d * step
