extends Node2D

var current_game: Node = null
var won_games := 0
var lifes := 3
@onready var timer: Timer = $Timer

@onready var timer_label: Label = $CanvasLayer/Panel/HBoxContainer/TimerLabel
@onready var score_label: Label = $CanvasLayer/Panel/HBoxContainer/ScoreLabel
@onready var lifes_label: Label = $CanvasLayer/Panel/HBoxContainer/LifesLabel

func _ready() -> void:
	next_game()

func _process(_delta: float) -> void:
	timer_label.text = String.num(timer.time_left, 1) + " s"
	score_label.text = "Score: " + str(won_games)
	lifes_label.text = "Lifes: " + str(lifes)

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
	timer.stop()
	if lifes <= 0:
		current_game.queue_free()

		get_parent().show_scoreboard(won_games)
		queue_free()
	else:
		next_game()
