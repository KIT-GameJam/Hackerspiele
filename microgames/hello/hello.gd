extends MicroGame

@onready var button: Button = find_child("HelloButton")
@onready var label: Label = find_child("HelloLabel")
var not_negations := randi_range(0, 5)
var dont_negations := randi_range(0, 1)
var negations := not_negations + dont_negations
var should_click := negations % 2 == 0

func _ready() -> void:
	var nots := "not ".repeat(not_negations)
	var donts := "n't".repeat(dont_negations)
	label.text = "Do{0} {1}click the button!".format([donts, nots])

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
