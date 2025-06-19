extends MicroGame

const level_scenes := [
	preload("res://microgames/martian_mike/levels/level0.tscn"),
	preload("res://microgames/martian_mike/levels/level1.tscn"),
	preload("res://microgames/martian_mike/levels/level2.tscn"),
]

func _ready() -> void:
	var level_idx := 1
	var level: MartianMikeLevel = level_scenes.pick_random().instantiate()
	time = level.level_time
	level.win.connect(_on_win)
	add_child(level)
	

func _on_win() -> void:
	finished.emit(Result.Win)
