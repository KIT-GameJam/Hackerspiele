class_name Game2048 extends MicroGame

@onready var digit = preload("res://microgames/2048/entities/digit.tscn")
@onready var digit_container = $Digits
@onready var ray_cast = $RayCast2D
@onready var goal_label = $Goal

@export var start_digits := 16

@export var max_exponent := 5

@export var grid_size := Vector2(5, 5)

@export var area_size := Vector2(500, 500)

@export var digit_speed := 1000

@export var round_timer := 0.5

var base = 2

var current_direction := Vector2.ZERO
var last_direction := Vector2.ZERO

const digit_size := 75

var all_grid_positions: Array[Vector2] = []

var _currentDelta = round_timer
var _has_spawned_next = true

var latest_digit: Game2048_Digit;

func _ready() -> void:
	base = randi_range(2, 5)
	var wins = storage.get("2048_Wins", 0)
	max_exponent += wins
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			all_grid_positions.append(Vector2(x, y))
	
	all_grid_positions.shuffle()
	
	var digit: Game2048_Digit
	for i in range(0, start_digits):
		digit = _spawn_digit(all_grid_positions[i])
	
	goal_label.text = "Reach " + str(digit.base ** max_exponent)
	

func _process(_delta):
	_currentDelta += _delta
	if (_currentDelta < round_timer):
		_has_spawned_next = false
		_apply_velocity(current_direction)
		return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	if (direction.is_zero_approx()):
		_apply_velocity(current_direction)
		return
	
	if (not direction.is_zero_approx()):
		if (abs(direction.x) > abs(direction.y)):
			if (direction.x > 0):
				current_direction = Vector2(1, 0)
			else:
				current_direction = Vector2(-1, 0)
		else:
			if (direction.y > 0):
				current_direction = Vector2(0, 1)
			elif (direction.y < 0):
				current_direction = Vector2(0, -1)
	
	if (last_direction == current_direction):
		_apply_velocity(current_direction)
		return
	
	last_direction = current_direction
	_currentDelta = 0
	
	if (not _has_spawned_next):
		_has_spawned_next = true
		_new_round()
	
	_apply_velocity(current_direction)

func _new_round():
	var free_slot = _get_free_slot()
	if (free_slot.x < 0):
		print("YOU LOST!")
		finished.emit(Result.Loss)
	else:
		latest_digit = _spawn_digit(free_slot)

func _get_free_slot() -> Vector2:
	all_grid_positions.shuffle()
	
	for pos in all_grid_positions:
		ray_cast.target_position = _grid_pos_to_area_pos(pos)
		ray_cast.force_raycast_update()
		if not ray_cast.is_colliding():
			return pos
	
	return Vector2(-1, -1)
	
func _apply_velocity(dir: Vector2):
	for digit in digit_container.get_children():
		if latest_digit != digit:
			var rigid = (digit as RigidBody2D)
			rigid.linear_velocity = dir * digit_speed

func _spawn_digit(grid_pos: Vector2) -> Game2048_Digit:
	var node : Game2048_Digit = digit.instantiate()
	node.digit_collision.connect(_on_digit_collision)
	node.global_position = _grid_pos_to_area_pos(grid_pos)
	digit_container.add_child(node)
	node.base = base
	if (randi_range(0, 1) == 0):
		node.increase(max_exponent)
	return node

func _grid_pos_to_area_pos(grid_pos: Vector2):
	var pos = area_size / grid_size * grid_pos
	pos -= area_size / 2.0
	pos += Vector2.ONE * digit_size / 2.0
	return pos

func _area_pos_to_grid_pos(area_pos: Vector2):
	var pos = (area_pos + area_size / 2.0 - Vector2.ONE * digit_size / 2.0) / area_size / grid_size
	return pos
	
	
func _on_digit_collision(digit_a: Game2048_Digit, digit_b: Game2048_Digit) -> void:
	if (digit_a.get_number() != digit_b.get_number()):
		return
	
	digit_a.increase(max_exponent)
	digit_b.queue_free()
	
	if (digit_a.exponent == max_exponent):
		print("YOU WON!")
		var wins = storage.get("2048_Wins", 0)
		storage.set("2048_Wins", wins + 1)
		finished.emit(Result.Win)
