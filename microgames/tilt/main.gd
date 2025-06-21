extends MicroGame

@onready
var ball: PackedScene = preload("res://microgames/tilt/ball.tscn")

func _ready() -> void:
	spawn_ball()
	finished.emit(Result.Win)
	
func _process(delta: float) -> void:
	spawn_ball()
	
func spawn_ball():
	var ball_obj = ball.instantiate()
	add_child(ball_obj)

	
	
