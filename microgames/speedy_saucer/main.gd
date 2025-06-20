extends MicroGame

@onready var level_node = $Level
const levels := [
	preload("res://microgames/speedy_saucer/levels/level0.tscn"),
	preload("res://microgames/speedy_saucer/levels/level1.tscn"),
	preload("res://microgames/speedy_saucer/levels/level2.tscn"),
]

func _ready() -> void:
	var level: Maze = levels.pick_random().instantiate()
	level_node.add_child(level)
	level.win.connect(_on_win)
	level.loss.connect(_on_loose)

func _on_win():
	finished.emit(Result.Win)

func _on_loose():
	finished.emit(Result.Loss)
