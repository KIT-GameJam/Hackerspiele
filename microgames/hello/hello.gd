extends MicroGame

@onready var button: Button = find_child("HelloButton")
@onready var label: Label = find_child("HelloLabel")
var negations := randi_range(0, 5)
var should_click := negations % 2 == 0

func _ready() -> void:
	var nots := "not ".repeat(negations)
	label.text = "Do " + nots + "click the button!"

func _on_button_pressed() -> void:
	finished.emit(Result.Win if should_click else Result.Loss)

func on_timeout() -> Result:
	return Result.Loss if should_click else Result.Win
