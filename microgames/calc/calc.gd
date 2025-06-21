extends MicroGame

var result = 0;
var user_input = "";
var correct = false;
@onready var user_input_node = find_child("UserInput")
@onready var task_node = find_child("Task")

func _ready() -> void:
	user_input_node.label_settings.font_color = Color("#d75145")
	var first := randi_range(-10, 10);
	var second := randi_range(-100, 100);
	var op_index := randi_range(0, 2);
	var op := "+";

	match op_index:
		1:
			op = "-"
			result = first - second
		2:
			op = "*"
			result = first * second
		_:
			op = "+"
			result = first + second
	if first < 0 && second < 0:
		task_node.text = "({0}){1}({2})".format([first, op, second])
	elif first < 0:
		task_node.text = "({0}){1}{2}".format([first, op, second])
	elif second < 0:
		task_node.text = "{0}{1}({2})".format([first, op, second])
	else:
		task_node.text = "{0}{1}{2}".format([first, op, second])
	find_child("7").grab_focus.call_deferred()
	for button in find_children("*", "Button"):
		button.pressed.connect(_on_click.bind(button))

func _on_click(button: Button) -> void:

	match button.name:
		"AC":
			user_input = ""
		"Delete":
			user_input = user_input.erase(user_input.length() - 1, 1)
		"=":
			if int(user_input) == result:
				user_input_node.label_settings.font_color = Color("#669e5d")
				correct = true
				await get_tree().create_timer(0.2).timeout
				finished.emit(Result.Win)
			else:
				user_input_node.label_settings.font_color = Color("#a70233")
				await get_tree().create_timer(0.3).timeout
				user_input_node.label_settings.font_color = Color("#d75145")

				#await get_tree().create_timer(0.5).timeout
				#user_input_node.label_settings.font_color = Color(215, 81, 69)
		_:
			user_input += button.name
	user_input_node.text = "{0}".format([user_input])

func on_timeout() -> Result:
	return Result.Win if correct else Result.Loss
