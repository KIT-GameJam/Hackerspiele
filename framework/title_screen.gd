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
var print_queue: Array[PrintEvent] = []
## true if currently waiting for input, false otherwise
var waiting_for_input := false

signal key_input(chr: String)

@export var SCOREBOARD_SIZE := 5
var scoreboard := []

const GameManager: PackedScene = preload("res://framework/game_manager.tscn")

enum PrintEventType { CHAR, BUTTON }

class PrintEvent:
	var ty: PrintEventType
	var val
	var onclick: Callable
	func _init(ty: PrintEventType, val) -> void:
		self.ty = ty
		self.val = val

func _ready() -> void:
	clear_terminal()
	push_str("\n\n\n")
	push_str("     +>+>+>+ Häckerspiele +<+<+<+\n")
	push_str(" >>>>>>>>>>>>============<<<<<<<<<<<<\n\n")
	push_str("     ")
	put_button(" Start ", _on_start_button_pressed)
	update_cursor_pos()
	update_poweroff_button_color(POWEROFF_COLOR_INACTIVE)

func on_button() -> void:
	print("hallo")

func _process(delta: float) -> void:
	while blink_time <= 0.0:
		blink_time += BLINK_SPEED
		toggle_cursor_visible()
	blink_time -= delta
	while print_queue and print_time <= 0.0:
		pop_print_queue()
		print_time += PRINT_TIMEOUT
	if print_queue:
		print_time -= delta
	else:
		print_time = 0.0
	update_screen_pos()

func _unhandled_key_input(event: InputEvent) -> void:
	if print_queue.is_empty() and waiting_for_input:
		if event.is_pressed():
			var key: Key = event.key_label
			if key == KEY_ENTER:
				key_input.emit("")
			elif key >= KEY_A and key <= KEY_Z:
				key_input.emit(OS.get_keycode_string(key))

func clear_terminal() -> void:
	label.text = ""
	for row in range(TERM_H):
		for _col in range(TERM_W):
			label.text += " "
		if row != TERM_H - 1:
			label.text += "\n"
	print_queue.clear()
	cursor = Vector2i.ZERO
	update_cursor_pos()
	while label.get_child_count() > 0:
		var child = label.get_child(0)
		label.remove_child(child)
		child.queue_free()

func put_button(s: String, onclick: Callable) -> void:
	var event := PrintEvent.new(PrintEventType.BUTTON, s)
	event.onclick = onclick
	print_queue.append(event)

func push_str(s: String):
	for chr in s:
		print_queue.append(PrintEvent.new(PrintEventType.CHAR, chr))

func pop_print_queue() -> void:
	var event: PrintEvent = print_queue.pop_front()
	match event.ty:
		PrintEventType.CHAR:
			putc(event.val)
		PrintEventType.BUTTON:
			var text: String = event.val
			for chr in text.reverse():
				print_queue.push_front(PrintEvent.new(PrintEventType.CHAR, chr))
			label.add_child(create_terminal_button(text, event.onclick))

func create_terminal_button(text: String, onclick: Callable) -> Button:
	var button := Button.new()
	var bounds := get_cursor_char_bounds()
	button.position = bounds.position
	button.size = bounds.size * Vector2(text.length(), 1.0)
	button.tooltip_text = text
	button.connect("pressed", onclick)
	return button

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

func get_cursor_char_bounds() -> Rect2:
	return label.get_character_bounds(get_char_index(cursor.y, cursor.x))

func update_cursor_pos() -> void:
	var bounds := get_cursor_char_bounds()
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


func disable() -> void:
	hide()
	screen_layer.hide()

func enable() -> void:
	show()
	screen_layer.show()

func _on_start_button_pressed() -> void:
	disable()
	var game_manager := GameManager.instantiate()
	add_child(game_manager)
	game_manager.tree_exited.connect(enable)

func scoreboard_position(score: int) -> int:
	var size := scoreboard.size()
	for i in range(size):
		var entry = scoreboard[i]
		if score > entry[1]:
			return i
	return size

func show_scoreboard(score: int) -> void:
	clear_terminal()
	var pos := scoreboard_position(score)
	print()
	if pos < SCOREBOARD_SIZE:
		push_str("Enter your name:\n")
		waiting_for_input = true
		var scoreboard_name := ""
		while true:
			var chr = await key_input
			if chr.is_empty():
				push_str("\n")
				break
			scoreboard_name += chr
			push_str(chr)
		waiting_for_input = false
		scoreboard.insert(pos, [scoreboard_name, score])
		scoreboard.resize(min(scoreboard.size(), SCOREBOARD_SIZE))

	# print scoreboard
	clear_terminal()
	push_str("Scoreboard\n")
	push_str("==========\n")
	for i in range(scoreboard.size()):
		var entry = scoreboard[i]
		push_str(str(i + 1) + ".  " + str(entry[1]) + "  " + entry[0] + "\n")
