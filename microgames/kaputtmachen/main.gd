extends MicroGame

const CANON_POS := Vector2i(8, 75)
const INITIAL_BALL_SPEED := 360.0
const ROTATION_SPEED := 1.5
const GRAVITY := 1200.0
const EXPLOSION_RADIUS := 3
const SHOOT_TIMEOUT := 0.32

@onready var image: Image = preload("res://microgames/kaputtmachen/assets/viewport.png").get_image()
@onready var dim := Vector2i(image.get_size())
@onready var texture_rect: TextureRect = $CanvasLayer/HBoxContainer/TextureRect
@onready var canon: Sprite2D = $Canon
@onready var ball: Sprite2D = $Ball

var ball_pos_old: Vector2
var ball_pos: Vector2
var ball_vel: Vector2
var image_updated := false
var shoot_timer := 0.0

func _ready() -> void:
	texture_rect.texture = ImageTexture.create_from_image(image)

func get_ratio() -> Vector2:
	return texture_rect.size / Vector2(dim)

func to_global(pos: Vector2) -> Vector2:
	return texture_rect.global_position + pos * get_ratio()

func _process(delta: float) -> void:
	shoot_timer -= delta
	canon.scale = get_ratio()
	ball.scale = get_ratio()
	canon.position = to_global(CANON_POS)
	if not ball.visible and shoot_timer <= 0.0 and Input.is_action_just_pressed("submit"):
		shoot_timer = SHOOT_TIMEOUT
		ball.visible = true
		ball_pos = CANON_POS
		ball_pos_old = ball_pos
		ball_vel = Vector2.from_angle(canon.rotation - PI * 0.25) * INITIAL_BALL_SPEED
	var dir := 0
	if Input.is_action_pressed("left") or Input.is_action_pressed("down"):
		dir -= 1
	elif Input.is_action_pressed("right") or Input.is_action_pressed("up"):
		dir += 1
	if dir:
		canon.rotation += float(dir) * ROTATION_SPEED * delta
	if not Rect2i(Vector2i.ZERO, dim).has_point(ball_pos):
		ball.visible = false
	if ball.visible:
		ball_pos += ball_vel * delta
		walk_line(ball_pos_old, ball_pos)
		ball_pos_old = ball_pos
		ball_vel.y += GRAVITY * delta
		ball.position = to_global(ball_pos)
	if image_updated:
		var tex: ImageTexture = texture_rect.texture
		tex.update(image)

func walk_line(start: Vector2, end: Vector2):
	var steps := int(roundf(start.distance_to(end)))
	for step in range(steps + 1):
		var pos = start + (end - start) * (float(step) / float(steps))
		if handle_pixel(Vector2i(pos.round())):
			return

func handle_pixel(pos: Vector2i) -> bool:
	var pixel := image.get_pixelv(pos)
	if pixel != Color.BLACK:
		ball.visible = false
		for y in range(-EXPLOSION_RADIUS, EXPLOSION_RADIUS):
			for x in range(-EXPLOSION_RADIUS, EXPLOSION_RADIUS):
				var px_pos := Vector2i(pos) + Vector2i(x, y)
				var px := image.get_pixelv(px_pos)
				if px == Color.WHITE:
					image.set_pixelv(px_pos, Color.BLACK)
				elif px != Color.BLACK:
					finished.emit(Result.Win)
					return true
		image_updated = true
		return true
	return false
