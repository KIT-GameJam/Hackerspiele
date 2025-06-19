extends MicroGame

@onready var level_node = $Level
const level_count := 2
const level_scenes := [
	preload("res://microgames/speedy_saucer/levels/level0.tscn"),
	preload("res://microgames/speedy_saucer/levels/level1.tscn"),
] 

func _ready() -> void:
	var random_level_idx = randi_range(0, level_count - 1)
	var level: Maze = level_scenes[random_level_idx].instantiate()
	level_node.add_child(level)
	level.win.connect(_on_win)
	level.loss.connect(_on_loose)

func _on_win():
	finished.emit(Result.Win)

func _on_loose():
	finished.emit(Result.Loss)
