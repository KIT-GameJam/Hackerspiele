extends MicroGame
@onready var fly: Area2D = $Fly
var _flygoal: Vector2 = Vector2.ZERO
var _speed: int = 3
var _flypoints: Array[Vector2]
var _fly_len: int = 0

func _ready() -> void:
	for p in $Flypoints.get_children():
		_flypoints.append(p.position)
	_fly_len = _flypoints.size()
	_timer()

func _process(delta: float) -> void:
	fly.position = fly.position.lerp(_flygoal, _speed*delta)

func _timer() -> void:
	get_tree().create_timer((randf()) + 0.5).timeout.connect(_move_fly)

func _move_fly() -> void:
	_flygoal = _flypoints[randi() % _fly_len]
	_speed = 3 + (randi() % 3)
	_timer()

func _on_swatter_body_fly_swatted() -> void:
	finished.emit(Result.Win)
