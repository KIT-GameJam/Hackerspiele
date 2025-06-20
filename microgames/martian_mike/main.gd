extends MicroGame

const level_scenes := [
	preload("res://microgames/martian_mike/levels/level0.tscn"),
	preload("res://microgames/martian_mike/levels/level1.tscn"),
	preload("res://microgames/martian_mike/levels/level2.tscn"),
]

func _ready() -> void:
	if not storage.has("next_level_idx") or storage.next_level_idx >= level_scenes.size():
		storage.next_level_idx = 0
	var level: MartianMikeLevel = level_scenes[storage.next_level_idx].instantiate()
	time = level.level_time
	level.win.connect(_on_win)
	add_child(level)
	storage.next_level_idx += 1

func _on_win() -> void:
	finished.emit(Result.Win)
