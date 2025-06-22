class_name Game2048_Digit extends RigidBody2D

@export var exponent := 0;
@export var base := 2;

@onready var label: Label = $Label
@onready var colorRect: ColorRect = $ColorRect
@onready var tester: Area2D = $Tester

@export var colors : Array[Color] = []
@export var start_color: Color
@export var end_color: Color

@export var font_size = 60

signal digit_collision(digit_a: Game2048_Digit, digit_b: Game2048_Digit)

func _process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	if (direction.is_zero_approx()):
		return

	var rotation = 0
	if (abs(direction.x) > abs(direction.y)):
		if (direction.x > 0):
			rotation = 90
		else:
			rotation = -90
	else:
		if (direction.y > 0):
			rotation = 180
		elif (direction.y < 0):
			rotation = 0

	tester.global_rotation_degrees = rotation


func get_number() -> int:
	return base ** exponent

func increase(max_exponent: int):
	exponent += 1
	var weight = float(exponent) / max_exponent
	colorRect.color = start_color.lerp(end_color, weight)
	label.text = str(get_number())
	label.add_theme_font_size_override("normal_font_size", font_size)
	if get_number() >= 100:
		label.add_theme_font_size_override("normal_font_size", font_size / 2)

func _on_tester_body_entered(body: Node2D) -> void:
	if (body is Game2048_Digit):
		digit_collision.emit(self, body)
