extends MicroGame

@export var level_count := 11

@onready var player: Control = $CanvasLayer2/Player
@onready var level_container: HBoxContainer = find_child("LevelContainer")
@onready var speech_label: Label = find_child("SpeechLabel")
@onready var arrow: Control = find_child("Arrow")

var level := 0
var button_rot: int
const BUTTON_NAMES := ["right", "down", "left", "up"]

func _ready() -> void:
	var first_level: Control = level_container.get_child(0)
	for i in range(level_count - 1):
		level_container.add_child(first_level.duplicate())
	new_text()
	new_button()

func _process(delta: float) -> void:
	var node: CanvasItem = level_container.get_child(level)
	player.global_position = node.global_position - Vector2(10.0, player.size.y)
	for btn in range(4):
		if Input.is_action_just_pressed(BUTTON_NAMES[btn]):
			if btn == button_rot:
				level += 1
			else:
				level = 0
			if level >= level_count:
				finished.emit(Result.Win)
			new_button()
			break

func new_text() -> void:
	speech_label.text = [
		"Please merge my\nPull Request!",
		"Merge it!",
		"The PR needs to be\nmerged yesterday!",
		"Why didn't you merge\nmy PR?!",
		"Finally do your work\nnow!",
		"Stop procrastinating!"
	].pick_random()

func new_button() -> void:
	button_rot = randi_range(0, 3)
	arrow.rotation_degrees = 90 * button_rot
