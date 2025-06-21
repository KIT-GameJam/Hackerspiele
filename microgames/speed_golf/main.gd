extends MicroGame

var cellId

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var ballTileCoord = $TileMapLayer.local_to_map($Ball.position)
	cellId = $TileMapLayer.get_cell_source_id(ballTileCoord)
	if cellId == 4:
		finished.emit(Result.Win)
	elif cellId == -1:
		finished.emit(Result.Loss)
