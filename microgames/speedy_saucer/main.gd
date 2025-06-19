extends MicroGame

@onready var level_node = $Level
const level_scene := preload("res://microgames/speedy_saucer/levels/level0.tscn")

func _ready() -> void:
	var level: Maze = level_scene.instantiate()
	level_node.add_child(level)
	level.win.connect(_on_win)
	level.loss.connect(_on_loose)

func _on_win():
	finished.emit(Result.Loss)

func _on_loose():
	finished.emit(Result.Win)
