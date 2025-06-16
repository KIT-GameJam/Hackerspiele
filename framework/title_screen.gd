extends Node3D

@export var BLINK_SPEED: float
@export var PRINT_TIMEOUT: float
@export var TERM_W: int
@export var TERM_H: int

const POWEROFF_COLOR_INACTIVE := Color("#cd5424")
const POWEROFF_COLOR_ACTIVE := Color("#ed7444")

@onready var camera: Camera3D = $Camera
@onready var marker_top_left: Marker3D = $Monitor/MarkerTopLeft
@onready var marker_top_right: Marker3D = $Monitor/MarkerTopRight
@onready var marker_bottom_right: Marker3D = $Monitor/MarkerBottomRight
@onready var screen_layer: CanvasLayer = $Monitor/ScreenLayer
@onready var screen: Panel = $Monitor/ScreenLayer/Screen
@onready var label: Label = $Monitor/ScreenLayer/Screen/Label
@onready var cursor_rect: Panel = $Monitor/ScreenLayer/Screen/CursorRect
@onready var poweroff_button: MeshInstance3D = $Monitor/PoweroffButton
var blink_time := 0.0
var print_time := 0.0
var cursor := Vector2i(0, 0)
var print_queue := []

const GameManager: PackedScene = preload("res://framework/game_manager.tscn")

func _ready() -> void:
	label.text = ""
	for row in range(TERM_H):
		for _col in range(TERM_W):
			label.text += " "
		if row != TERM_H - 1:
			label.text += "\n"
	push_str("\n\n\n")
	push_str("    +>+>+>+ Häckerspiele +<+<+<+\n")
	push_str(">>>>>>>>>>>>============<<<<<<<<<<<<\n\n")
	update_cursor_pos()
	update_poweroff_button_color(POWEROFF_COLOR_INACTIVE)

func _process(delta: float) -> void:
	while blink_time <= 0.0:
		blink_time += BLINK_SPEED
		toggle_cursor_visible()
	blink_time -= delta
	while print_queue and print_time <= 0.0:
		putc(print_queue.pop_front())
		print_time += PRINT_TIMEOUT
	if print_queue:
		print_time -= delta
	else:
		print_time = 0.0
	update_screen_pos()

func push_str(s: String):
	for chr in s:
		print_queue.append(chr)

func get_char_index(row: int, col: int) -> int:
	return col + row * (TERM_W + 1)

func setc(row: int, col: int, chr: String) -> void:
	label.text[get_char_index(row, col)] = chr

func next_row() -> void:
	cursor.x = 0
	if cursor.y == TERM_H - 1:
		label.text = label.text.substr(TERM_W + 1) + "\n" + " ".repeat(TERM_W)
	else:
		cursor.y += 1

func putc(chr: String) -> void:
	if chr == "\n":
		next_row()
	else:
		setc(cursor.y, cursor.x, chr)
	if cursor.x == TERM_W - 1:
		next_row()
	else:
		cursor.x += 1
	update_cursor_pos()

func update_cursor_pos() -> void:
	var bounds := label.get_character_bounds(get_char_index(cursor.y, cursor.x))
	cursor_rect.position = label.position + bounds.position
	cursor_rect.position.y += bounds.size.y - cursor_rect.size.y

func toggle_cursor_visible() -> void:
	cursor_rect.visible = not cursor_rect.visible

func update_screen_pos() -> void:
	var top_left = camera.unproject_position(marker_top_left.global_position)
	var top_right = camera.unproject_position(marker_top_right.global_position)
	var bottom_right = camera.unproject_position(marker_bottom_right.global_position)
	var x_axis: Vector2 = top_right - top_left
	var y_axis: Vector2 = bottom_right - top_right
	var scale_x := 1.0 / screen.size.x
	var scale_y := 1.0 / screen.size.y
	screen_layer.transform = Transform2D(x_axis * scale_x, y_axis * scale_y, top_left)

func update_poweroff_button_color(color: Color) -> void:
	var material : StandardMaterial3D = poweroff_button.get_active_material(0)
	material.albedo_color = color

func _on_poweroff_button_mouse_entered() -> void:
	update_poweroff_button_color(POWEROFF_COLOR_ACTIVE)

func _on_poweroff_button_mouse_exited() -> void:
	update_poweroff_button_color(POWEROFF_COLOR_INACTIVE)

func _on_poweroff_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager)
