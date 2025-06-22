extends MicroGame

@onready
var ball: PackedScene = preload("res://microgames/tilt/ball.tscn")
var runtime: float = 0;
var round: int = 1;

func timer_function(_round: int):
	return (200 / (_round + 40))

func _ready() -> void:
	spawn_ball()

func on_timeout() -> Result:
	return Result.Win

func _process(delta: float) -> void:
	runtime += delta
	if runtime >= timer_function(round):
		round += 1
		runtime = 0
		spawn_ball()

func ball_finished():
	round += 1
	runtime = 0
	spawn_ball()

func spawn_ball():
	var ball_obj = ball.instantiate()
	add_child(ball_obj)

func end():
	finished.emit(Result.Loss)
