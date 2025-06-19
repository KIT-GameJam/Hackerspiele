extends MicroGame

@onready var level_node = $Level
const level_count := 3
const level_paths := [
	"res://microgames/speedy_saucer/levels/level0.tscn",
	"res://microgames/speedy_saucer/levels/level1.tscn",
	"res://microgames/speedy_saucer/levels/level2.tscn",
] 

func _ready() -> void:
	var random_level_idx = randi_range(0, level_count - 1)
	var level_scene = load(level_paths[random_level_idx])
	var level: Maze = level_scene.instantiate()
	level_node.add_child(level)
	level.win.connect(_on_win)
	level.loss.connect(_on_loose)

func _on_win():
	finished.emit(Result.Win)

func _on_loose():
	finished.emit(Result.Loss)
