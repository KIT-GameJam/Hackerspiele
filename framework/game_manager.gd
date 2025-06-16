extends Node2D

var current_game: Node = null
var won_games := 0
var lifes := 3
@onready var timer: Timer = $Timer

@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var lifes_label: Label = $CanvasLayer/LifesLabel

func _ready() -> void:
	next_game()

func _process(_delta: float) -> void:
	timer_label.text = String.num(timer.time_left, 1) + " s"
	score_label.text = str(won_games)
	lifes_label.text = str(lifes)

func next_game() -> void:
	if current_game:
		current_game.queue_free()
	var scene: PackedScene = MicroGames.scenes.pick_random()
	current_game = scene.instantiate()
	add_child(current_game)
	timer.timeout.connect(current_game._on_timeout)
	current_game.win.connect(game_won)
	current_game.loss.connect(game_loss)
	timer.start()

func game_won() -> void:
	print("you won")
	won_games += 1
	timer.stop()
	next_game()

func game_loss() -> void:
	print("you lost")
	lifes -= 1
	timer.stop()
	if lifes <= 0:
		print("rip")
		print("Score: ", won_games)
		current_game.queue_free()
	else:
		next_game()
