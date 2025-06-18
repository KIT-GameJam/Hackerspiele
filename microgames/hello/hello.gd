extends MicroGame

@onready var button: Button = find_child("HelloButton")
@onready var label: Label = find_child("HelloLabel")
var not_negations := randi_range(0, 5)
var dont_negations := randi_range(0, 1)
var really_count := randi_range(0, 1)
var negations := not_negations + dont_negations
var should_click := negations % 2 == 0

func _ready() -> void:
	var nots := "not ".repeat(not_negations)
	var donts := "n't".repeat(dont_negations)
	var really := "Really do" if really_count else "Do"
	label.text = "{0}{1} {2}click the button!".format([really, donts, nots])

func _process(_delta: float) -> void:
	if Input.is_action_pressed("submit"):
		_on_button_pressed()

func _on_button_pressed() -> void:
	finished.emit(Result.Win if should_click else Result.Loss)

func on_timeout() -> Result:
	return Result.Loss if should_click else Result.Win
