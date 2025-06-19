extends MicroGame

var level_scenes: Array[PackedScene] = [
	preload("res://microgames/coin_collector/levels/level0.tscn")
]

func _ready() -> void:
	var level = level_scenes.pick_random().instantiate()
	level.win.connect(_on_win)
	add_child(level)

func _on_win():
	finished.emit(Result.Win)
