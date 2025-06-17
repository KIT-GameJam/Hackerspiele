extends MicroGame

@onready var button: Button = $CanvasLayer/Button
var negations := randi_range(0, 5)
var should_click := negations % 2 == 0

func _ready() -> void:
	var nots := "not ".repeat(negations)
	button.text = "Do " + nots + "click this button!"

func _on_button_pressed() -> void:
	if should_click:
		win.emit()
	else:
		loss.emit()

func on_timeout() -> void:
	if should_click:
		loss.emit()
	else:
		win.emit()
