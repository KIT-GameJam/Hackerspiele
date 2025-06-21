extends MicroGame

var pulled_carrots : int = 0

func _ready() -> void:
	var grass_manager = get_node("SubViewportContainer/SubViewport/grass_manager")
	grass_manager.spawn_grass()

func carrot_pulled() -> void:
	pulled_carrots += 1
	$CanvasLayer/Label.text = "COLLECT CARROTS ( "+ str(pulled_carrots) +" / 5 )"
	if pulled_carrots >= 5:
		finished.emit(Result.Win)
