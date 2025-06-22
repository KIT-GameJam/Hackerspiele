extends MicroGame

@export var speed := 1.0
@export var rotation_speed := 5.0
@export var num_rotations := 10

@onready var ball: Node3D = $Ball
@onready var cups := find_children("*", "Cup")
@onready var pivot: Node3D = $Pivot

enum Mode { IDLE, HIDE, SHOW, ROTATE, SELECT }

const y_offset := 1.5

var ball_idx: int
var mode := Mode.IDLE
var selected_cup_idx: int

signal hidden
signal shown
signal submit

func _ready() -> void:
	timer.paused = true

	if cups.size() < 2:
		push_warning("cups: less than two cups")

	# select ball position
	ball_idx = rand_cup_idx()
	ball.position = cups[ball_idx].position
	for cup in cups:
		cup.position.y += y_offset
	mode = Mode.HIDE
	await hidden
	ball.hide()

	for _i in range(num_rotations):
		var cup1_idx := rand_cup_idx()
		var cup2_idx := rand_cup_idx()
		while cup1_idx == cup2_idx:
			cup2_idx = rand_cup_idx()
		await swap(cup1_idx, cup2_idx)

	ball.position = cups[ball_idx].position
	ball.show()
	selected_cup_idx = 0
	cups[selected_cup_idx].outline(true)
	mode = Mode.SELECT
	timer.paused = false
	await submit
	timer.paused = true
	mode = Mode.SHOW
	await shown
	finished.emit(Result.Win if selected_cup_idx == ball_idx else Result.Loss)

func _process(delta: float) -> void:
	match mode:
		Mode.HIDE:
			var all := true
			for cup in cups:
				cup.translate(Vector3(0.0, -speed, 0.0) * delta)
				if cup.position.y <= 0.0:
					cup.position.y = 0.0
				else:
					all = false
			if all:
				mode = Mode.IDLE
				hidden.emit()
		Mode.SHOW:
			var all := true
			for cup in cups:
				cup.translate(Vector3(0.0, speed, 0.0) * delta)
				if cup.position.y >= y_offset:
					cup.position.y = y_offset
				else:
					all = false
			if all:
				mode = Mode.IDLE
				shown.emit()
		Mode.ROTATE:
			pivot.rotate_y(rotation_speed * delta)

func _input(event: InputEvent) -> void:
	if mode == Mode.SELECT:
		if event.is_action_pressed("submit"):
			submit.emit()
		elif event.is_action_pressed("left"):
			cups[selected_cup_idx].outline(false)
			selected_cup_idx = posmod(selected_cup_idx - 1, cups.size())
			cups[selected_cup_idx].outline(true)
		elif event.is_action_pressed("right"):
			cups[selected_cup_idx].outline(false)
			selected_cup_idx = posmod(selected_cup_idx + 1, cups.size())
			cups[selected_cup_idx].outline(true)

func rand_cup_idx() -> int:
	return randi_range(0, cups.size() - 1)

func swap(cup1_idx: int, cup2_idx: int) -> void:
	if cup1_idx == cup2_idx:
		return
	if ball_idx == cup1_idx:
		ball_idx = cup2_idx
	elif ball_idx == cup2_idx:
		ball_idx = cup1_idx

	var cup1: Cup = cups[cup1_idx]
	var cup2: Cup = cups[cup2_idx]
	var cup1_position := cup1.position
	var cup2_position := cup2.position
	pivot.position = (cup1_position + cup2_position) / 2
	cup1.reparent(pivot, true)
	cup2.reparent(pivot, true)
	mode = Mode.ROTATE
	await get_tree().create_timer(PI / rotation_speed).timeout
	mode = Mode.IDLE
	cup1.reparent(self, true)
	cup2.reparent(self, true)
	cup1.position = cup2_position
	cup2.position = cup1_position
	cups[cup1_idx] = cup2
	cups[cup2_idx] = cup1

func swap_stop() -> void:
	for cup in pivot.get_children():
		cup.reparent(self)

func on_timeout() -> Result:
	return Result.Win
