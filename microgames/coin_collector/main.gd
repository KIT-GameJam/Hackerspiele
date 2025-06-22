extends MicroGame

var level_scenes: Array[PackedScene] = [
	preload("res://microgames/coin_collector/levels/level0.tscn"),
	preload("res://microgames/coin_collector/levels/level1.tscn"),
	preload("res://microgames/coin_collector/levels/level2.tscn"),
]
var curr_level: Node2D
var curr_level_idx: int = 0

func _ready() -> void:
	var level_idx = randi_range(0, level_scenes.size() - 1)
	_load_level(level_idx)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("submit"):
		curr_level.queue_free()
		_load_level(curr_level_idx)

func _load_level(idx: int):
	var level = level_scenes[idx].instantiate()
	level.win.connect(_on_win)
	curr_level = level
	curr_level_idx = idx
	add_child(level)

func _on_win():
	finished.emit(Result.Win)

