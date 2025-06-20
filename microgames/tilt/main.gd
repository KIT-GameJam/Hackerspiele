extends MicroGame


func _ready() -> void:
	var scene = load("res://microgames/tilt/ball.tscn")
	var player = scene.instance()
	add_child(player)
	finished.emit(Result.Win)



	
	
