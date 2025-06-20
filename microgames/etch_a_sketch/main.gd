class_name EtchASketchGame
extends MicroGame

@onready var drawing_rect: TextureRect = %DrawingRect
@onready var target_rect: TextureRect = %TargetRect
@onready var hand_left: Control = %HandLeft
@onready var hand_right: Control = %HandRight
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var etch_a_sketch: Control = %EtchASketch
@onready var postit: Control = %PostIt

@export var targets: Array[EtchTarget] = []

@export var size: Vector2i = Vector2i(420, 315)
@export var speed: float = 200.0
@export var pen_size: Vector2 = Vector2(5, 5)

@export var win_threshold: float = 0.45

var og_time: float = 9.0

var drawing: Image
var target_image: Image
var target_blur_image: Image

var position : Vector2 = size / 2.0

var progress_left: float = 4.0
var progress_right: float = 17.0

var max_score: float = 1.0

var done: bool = false

var etch_wiggle_progress: float = 0.0
var postit_wiggle_progress: float = 0.0

func _physics_process(delta: float) -> void:
	var step := Input.get_vector("left", "right", "up", "down") * speed * delta * (og_time / float(time))
	position += step
	position.x = clamp(position.x, 0, size.x)
	position.y = clamp(position.y, 0, size.y)

	if step.x != 0:
		progress_left += delta * 4.0 + sin(Time.get_ticks_msec() / 1000.0) * 0.5
	if step.y != 0:
		progress_right += delta * 4.0 + sin(Time.get_ticks_msec() / 1000.0) * 0.5

func _process(delta: float) -> void:
	if (!drawing or !target_blur_image):
		return

	drawing.fill_rect(Rect2(position - pen_size / 2, pen_size), Color.BLACK)
	drawing_rect.texture = ImageTexture.create_from_image(drawing)
	hand_left.rotation_degrees = 90 + sin(progress_left) * 5.0
	hand_right.rotation_degrees = 90 + sin(progress_right) * 5.0
	var score: float = calc_score()
	if score > win_threshold and not done:
		done = true
		finished.emit(Result.Win)
	progress_bar.value = score / win_threshold * 100.0
	etch_a_sketch.rotation_degrees = sin(etch_wiggle_progress) * 5.0
	postit.rotation_degrees = sin(postit_wiggle_progress) * 5.0
	etch_wiggle_progress += delta * 2.0
	postit_wiggle_progress += delta * 1.5

func calc_score() -> float:
	if (!drawing or !target_blur_image):
		return 0.0
	var score: float = 0.0
	for x in range(size.x):
		for y in range(size.y):
			var pixel: Color = drawing.get_pixel(x, y)
			if pixel.a > 0.0:
				var target_pixel: Color = target_blur_image.get_pixel(x, y)
				score += target_pixel.a
	return score / (size.x * size.y) / max_score * 1000000.0

func _ready() -> void:
	if targets.is_empty():
		finished.emit(Result.Win)
		return

	var target: EtchTarget = targets.pick_random()
	target_image = target.target.get_image()
	target_image.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)

	target_blur_image = target.target_blur.get_image()
	target_blur_image.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)

	for x in range(size.x):
		for y in range(size.y):
			var target_pixel: Color = target_blur_image.get_pixel(x, y)
			max_score += target_pixel.a

	target_rect.texture = ImageTexture.create_from_image(target_image)

	drawing = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
