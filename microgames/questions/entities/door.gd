extends Area2D

@onready var answer = $Answer
@export var id = 0

signal clicked

func set_answer(text: String):
	answer.text = text

func _on_button_pressed():
	clicked.emit(answer.text)

func reveal_correct():
	$DoorSprite.hide()
	$False.hide()
	$Answer.hide()

func reveal_false():
	$DoorSprite.hide()
	$Correct.hide()
	$Answer.hide()
