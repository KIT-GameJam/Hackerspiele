extends Node2D

var current_game: Node = null
var won_games := 0
var lifes := 3
@onready var timer: Timer = $Timer
@onready var timer_progress: TextureProgressBar = $CanvasLayer/Panel/HBoxContainer/TimerProgress

@onready var timer_label: Label = $CanvasLayer/Panel/HBoxContainer/TimerLabel
@onready var score_label: Label = $CanvasLayer/Panel/HBoxContainer/ScoreLabel

@onready var heart_container: HBoxContainer = $CanvasLayer/Panel/HBoxContainer/HeartContainer
@onready var heart_template: TextureRect = $CanvasLayer/Panel/HBoxContainer/HeartContainer/Heart
var hearts: Array[TextureRect] = []

func _ready() -> void:
	update_life_count()
	next_game()

func _process(_delta: float) -> void:
	timer_label.text = String.num(timer.time_left, 1) + " s"
	score_label.text = "Score: " + str(won_games)
	var progress: float = timer.time_left / timer.wait_time
	timer_progress.value = 100.0 * progress
	timer_progress.modulate = Color.from_hsv(0.33 * progress * progress, 0.8, 1.0)
	if Input.is_action_just_pressed("pause"):
		pause()

func pause() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	get_parent().pause()

func unpause() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func next_game() -> void:
	if current_game:
		current_game.queue_free()
	var scene: PackedScene = MicroGames.scenes.pick_random()
	current_game = scene.instantiate()
	add_child(current_game)
	timer.timeout.connect(current_game.on_timeout)
	current_game.win.connect(game_won)
	current_game.loss.connect(game_loss)
	timer.start()

func game_won() -> void:
	won_games += 1
	timer.stop()
	next_game()

func game_loss() -> void:
	lifes -= 1
	update_life_count()
	timer.stop()
	if lifes <= 0:
		current_game.queue_free()

		get_parent().show_scoreboard(won_games)
		queue_free()
	else:
		next_game()

func update_life_count() -> void:
	var missing: int = lifes - hearts.size()
	if missing > 0:
		for i in range(missing):
			var heart: TextureRect = heart_template.duplicate(0)
			heart.visible = true
			hearts.append(heart)
			heart_container.add_child(heart)
	elif missing < 0:
		for i in range(-missing):
			var heart: TextureRect = hearts.pop_back()
			heart_container.remove_child(heart)
			heart.queue_free()
