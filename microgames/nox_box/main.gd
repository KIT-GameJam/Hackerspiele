extends MicroGame

const box_scene = preload("res://microgames/nox_box/entities/box.tscn")

@export var num_boxes := 20.0
@onready var box_container := $Boxes
var spawn_positions = {
	"x": range(floor(-(num_boxes / 2.0)), ceil(num_boxes / 2.0)),
	"y": range(floor(-(num_boxes / 2.0)), ceil(num_boxes / 2.0)),
}
var num_box_childs = 0

func _ready() -> void:
	spawn_positions.x.shuffle()
	spawn_positions.y.shuffle()
	for i in range(0, num_boxes - 1):
		var spawn_pos = _get_spawn_pos(i)
		_spawn_box(spawn_pos)

func _spawn_box(pos: Vector2):
	var box = box_scene.instantiate()
	box.global_position = pos
	box_container.add_child(box)
	num_box_childs += 1

func _get_spawn_pos(idx: int) -> Vector2:
	var spawn_pos_idx = Vector2(spawn_positions.x[idx] * 20, spawn_positions.y[idx] * 10)
	return spawn_pos_idx

func _on_box_deathzone_entered(body: Node2D) -> void:
	num_box_childs -= 1
	body.queue_free()
	print(box_container.get_children().size())
	if num_box_childs == 0:
		finished.emit(Result.Win)
