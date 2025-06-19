extends Node2D
class_name GameManager

@export var max_lifes := 3
var current_game: MicroGame = null
var won_games: int
var lifes: int
var in_switch_state := false
@onready var timer: Timer = $MicrogameSlot/Timer
@onready var timer_progress: TextureProgressBar = $CanvasLayer/Panel/HBoxContainer/TimerProgress
@onready var switch_game_timer: Timer = $MicrogameSlot/SwitchGameTimer

@onready var timer_label: Label = $CanvasLayer/Panel/HBoxContainer/TimerLabel
@onready var score_label: Label = $CanvasLayer/Panel/HBoxContainer/ScoreLabel

@onready var heart_container: HBoxContainer = $CanvasLayer/Panel/HBoxContainer/HeartContainer
@onready var heart_template: TextureRect = $CanvasLayer/Panel/HBoxContainer/HeartContainer/Heart
var hearts: Array[TextureRect] = []

@onready var microgame_slot: Node = $MicrogameSlot
@onready var title_screen: TitleScreen = preload("res://framework/title_screen.tscn").instantiate()
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	show_title_screen()

func _process(_delta: float) -> void:
	if current_game:
		timer_label.text = String.num(timer.time_left, 1) + " s"
		var progress: float = timer.time_left / timer.wait_time
		timer_progress.value = 100.0 * progress
		timer_progress.modulate = Color.from_hsv(0.33 * progress * progress, 0.8, 1.0)
		score_label.text = "Score: " + str(won_games)
	if Input.is_action_just_pressed("pause"):
		if title_screen.is_paused:
			unpause()
		else:
			pause()

func show_title_screen() -> void:
	canvas_layer.hide()
	if title_screen.get_parent() != self:
		add_child(title_screen)

func hide_title_screen() -> void:
	canvas_layer.show()
	if title_screen.get_parent() == self:
		remove_child(title_screen)

func pause() -> void:
	if current_game == null and not in_switch_state:
		# pausing is only allowed in microgames and switch screen
		return
	if current_game:
		microgame_slot.process_mode = Node.PROCESS_MODE_DISABLED
		microgame_slot.remove_child(current_game)
	switch_game_timer.paused = true
	show_title_screen()
	title_screen.pause()

func unpause() -> void:
	if current_game:
		microgame_slot.add_child(current_game)
		microgame_slot.process_mode = Node.PROCESS_MODE_INHERIT
	if in_switch_state:
		# if unpaused while in switch screen, directly go to next microgame
		switch_game_timer.stop()
		start_game()
	hide_title_screen()
	switch_game_timer.paused = false
	title_screen.unpause()

func start() -> void:
	lifes = max_lifes
	won_games = 0
	update_life_count()
	title_screen.reset_bottles()
	start_game()

func next_game(was_successfull: bool) -> void:
	if current_game:
		current_game.queue_free()
		current_game = null
	in_switch_state = true
	show_title_screen()
	title_screen.add_bottle()
	switch_game_timer.start()
	title_screen.switch_game_screen(was_successfull)

func start_game() -> void:
	in_switch_state = false
	hide_title_screen()
	var scene: PackedScene = MicroGames.scenes.pick_random()
	current_game = scene.instantiate()
	microgame_slot.add_child(current_game)
	current_game.finished.connect(game_finished)
	timer.wait_time = current_game.time
	timer.timeout.connect(handle_timeout)
	timer.start()

func handle_timeout() -> void:
	game_finished(current_game.on_timeout())

func game_over() -> void:
	microgame_slot.remove_child(current_game)
	current_game.queue_free()
	current_game = null

	show_title_screen()
	title_screen.show_scoreboard(won_games)

func game_finished(result: MicroGame.Result) -> void:
	timer.stop()
	timer.timeout.disconnect(handle_timeout)
	var was_successfull: bool = false
	match result:
		MicroGame.Result.Loss:
			lifes -= 1
			update_life_count()
			if lifes <= 0:
				game_over()
				return
		MicroGame.Result.Win:
			won_games += 1
			was_successfull = true
	next_game(was_successfull)

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

func _on_switch_game_timer_timeout() -> void:
	start_game()
