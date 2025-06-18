extends Node3D
class_name TitleScreen

@export var PRINT_TIMEOUT: float
@export var TERM_W: int
@export var TERM_H: int

const POWEROFF_COLOR_INACTIVE := Color("#cd5424")
const POWEROFF_COLOR_ACTIVE := Color("#ed7444")
const SCOREBOARD_MAX_NAME_LEN := 20
const VOLUME_SLIDER_SIZE := 16
const VOLUME_SLIDER_FULL_CHAR := "▓"
const VOLUME_SLIDER_EMPTY_CHAR := "░"

@onready var camera: Camera3D = $Camera
@onready var marker_top_left: Marker3D = $Monitor/MarkerTopLeft
@onready var marker_top_right: Marker3D = $Monitor/MarkerTopRight
@onready var marker_bottom_right: Marker3D = $Monitor/MarkerBottomRight
@onready var screen_layer: CanvasLayer = $Monitor/ScreenLayer
@onready var screen: Panel = $Monitor/ScreenLayer/Screen
@onready var label: Label = $Monitor/ScreenLayer/Screen/Label
@onready var cursor_rect: Panel = $Monitor/ScreenLayer/Screen/CursorRect
@onready var poweroff_button: MeshInstance3D = $Monitor/PoweroffButton
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var blink_timer: Timer = $Monitor/ScreenLayer/Screen/BlinkTimer
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game-manager")
var print_time := 0.0
var cursor := Vector2i(0, 0)
var print_queue: Array[PrintEvent] = []
var environment_buffer: Environment = null
## true if currently waiting for input, false otherwise
var waiting_for_input := false
var is_paused := false

signal key_input(chr: String)

@export var SCOREBOARD_SIZE := 5
var scoreboard := []
const SCOREBOARD_PATH := "user://scoreboard.dat"

enum PrintEventType { CHAR, BUTTON, SYNC }

class PrintEvent:
	var ty: PrintEventType
	var val
	var onclick: Callable
	func _init(p_ty: PrintEventType, p_val) -> void:
		self.ty = p_ty
		self.val = p_val

func _ready() -> void:
	load_scoreboard()
	update_poweroff_button_color(POWEROFF_COLOR_INACTIVE)

	show_title_screen()

func _process(delta: float) -> void:
	while print_queue and print_time <= 0.0:
		pop_print_queue()
		var timeout := PRINT_TIMEOUT
		if Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
			timeout *= 0.15
		print_time += timeout
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
			elif key == KEY_BACKSPACE:
				key_input.emit("\b")
			elif (key >= KEY_A and key <= KEY_Z) or (key >= KEY_0 and key <= KEY_9):
				key_input.emit(OS.get_keycode_string(key))

func _on_blink_timer_timeout() -> void:
	# toggle cursor visibility
	cursor_rect.visible = not cursor_rect.visible

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

func put_button(text: String, onclick: Callable) -> void:
	var event := PrintEvent.new(PrintEventType.BUTTON, " " + text + " ")
	event.onclick = onclick
	print_queue.append(event)

func put_settings_button(text: String, on_click: Callable) -> void:
	push_str("-> ")
	put_button(text, on_click)
	push_str("\n")

func push_str(s: String):
	for chr in s:
		print_queue.append(PrintEvent.new(PrintEventType.CHAR, chr))

func push_sync(handler: Callable) -> void:
	var event := PrintEvent.new(PrintEventType.SYNC, null)
	event.onclick = handler
	print_queue.append(event)

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
		PrintEventType.SYNC:
			event.onclick.call()

func create_terminal_button(text: String, onclick: Callable) -> Button:
	var button := Button.new()
	var bounds := get_cursor_char_bounds()
	button.position = bounds.position
	button.size = bounds.size * Vector2(text.length(), 1.0)
	button.tooltip_text = text
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if get_viewport().gui_get_focus_owner() == null:
		button.grab_focus.call_deferred()
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

func backspace() -> void:
	if cursor.x != 0:
		cursor.x -= 1
	elif cursor.y > 0:
		cursor.x = TERM_W - 1
		cursor.y -= 1
	setc(cursor.y, cursor.x, " ")
	update_cursor_pos()

func get_cursor_char_bounds() -> Rect2:
	return label.get_character_bounds(get_char_index(cursor.y, cursor.x))

func update_cursor_pos() -> void:
	var bounds := get_cursor_char_bounds()
	cursor_rect.position = label.position + bounds.position
	cursor_rect.position.y += bounds.size.y - cursor_rect.size.y

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


# scoreboard

func _on_start_button_pressed() -> void:
	game_manager.start()

func scoreboard_position(score: int) -> int:
	var size := scoreboard.size()
	for i in range(size):
		var entry = scoreboard[i]
		if score > entry[1]:
			return i
	return size

func show_pause_screen() -> void:
	clear_terminal()
	push_str("Game Paused\n")
	push_str("-----------\n\n")
	put_settings_button("Settings", show_settings)
	push_str("\n")
	put_settings_button("Resume", unpause_game_manager)

func unpause_game_manager() -> void:
	game_manager.unpause()

func pause() -> void:
	is_paused = true
	show_pause_screen()

func unpause() -> void:
	is_paused = false

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
			if chr == "\b":
				if scoreboard_name:
					scoreboard_name = scoreboard_name.left(-1)
					backspace()
				continue
			if scoreboard_name.length() >= SCOREBOARD_MAX_NAME_LEN:
				continue
			scoreboard_name += chr
			push_str(chr)
		waiting_for_input = false
		scoreboard.insert(pos, [scoreboard_name, score])
		scoreboard.resize(min(scoreboard.size(), SCOREBOARD_SIZE))
		save_scoreboard()
	print_scoreboard(pos)
	push_str("Your score: " + str(score) + "\n\n")
	put_settings_button("play again", _on_start_button_pressed)
	return_to_title_screen_button()

func print_scoreboard(highlight_position := -1) -> void:
	clear_terminal()
	push_str("Scoreboard\n")
	push_str("==========\n")
	for i in range(scoreboard.size()):
		var entry = scoreboard[i]
		var score_text := str(entry[1]).rpad(6)
		var prefix := ">" if i == highlight_position else " "
		push_str(prefix + str(i + 1) + ".  " + score_text + entry[0] + "\n")
	push_str("\n")

func load_scoreboard() -> void:
	if FileAccess.file_exists(SCOREBOARD_PATH):
		print("loading scoreboard")
		var file = FileAccess.open(SCOREBOARD_PATH, FileAccess.READ)
		scoreboard = file.get_var()

func save_scoreboard() -> void:
	var file := FileAccess.open(SCOREBOARD_PATH, FileAccess.WRITE)
	file.store_var(scoreboard)


# menu

func print_game_title() -> void:
	push_str("\n\n\n")
	push_str("     +>+>+>+ Häckerspiele +<+<+<+\n")
	push_str(" >>>>>>>>>>>>============<<<<<<<<<<<<\n\n\n")
	push_str("            -> ")
	put_button("Start", _on_start_button_pressed)
	push_str("\n\n")
	push_str("            -> ")
	put_button("Settings", show_settings)
	push_str("\n")

func show_title_screen() -> void:
	clear_terminal()
	print_game_title()

func return_to_title_screen_button() -> void:
	put_settings_button("return to title screen", show_title_screen)

func return_to_settings_button() -> void:
	put_settings_button("return to settings", show_settings)

func change_volume(bus_idx: int, volume_cursor: Vector2i, delta: int):
	var val := linear_to_slider_volume(AudioServer.get_bus_volume_linear(bus_idx)) + delta
	AudioServer.set_bus_volume_linear(bus_idx, slider_volume_to_linear(val))
	update_volume_graphics(volume_cursor, val)

func update_volume_graphics(volume_cursor: Vector2i, val: int):
	for i in range(VOLUME_SLIDER_SIZE):
		var chr := VOLUME_SLIDER_FULL_CHAR if i < val else VOLUME_SLIDER_EMPTY_CHAR
		setc(volume_cursor.y, volume_cursor.x + val, chr)

func slider_volume_to_linear(val: int) -> float:
	return float(val) / VOLUME_SLIDER_SIZE

func linear_to_slider_volume(linear: float) -> int:
	return int(roundf(linear * float(VOLUME_SLIDER_SIZE)))

func put_volume_slider(name: String, bus_name: String, handler: Callable) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	push_str((name + ":").rpad(8))
	push_sync(func():
		var volume_cursor := cursor + Vector2i(2, 0)
		put_button("-", func():
			change_volume(bus_idx, volume_cursor, -1)
		)
		var volume_bars := linear_to_slider_volume(AudioServer.get_bus_volume_linear(bus_idx))
		push_sync(func():
			update_volume_graphics(volume_cursor, volume_bars)
			cursor.x += VOLUME_SLIDER_SIZE
			put_button("+", func():
				change_volume(bus_idx, volume_cursor, 1)
			)
			push_str("\n")
			handler.call()
		)
	)

func show_volume_settings() -> void:
	clear_terminal()
	push_str("Volume Settings\n")
	push_str("===============\n\n")
	put_volume_slider("Master", "Master", func():
		put_volume_slider("UI", "Ui", func():
			put_volume_slider("Music", "Music", func():
				return_to_settings_button()
			)
		)
	)

func show_settings() -> void:
	clear_terminal()
	push_str("Settings\n")
	push_str("========\n\n")
	put_settings_button("volume settings", show_volume_settings)
	put_settings_button("show scoreboard", func():
		print_scoreboard()
		return_to_settings_button()
	)
	put_settings_button("reset scoreboard", func():
		clear_terminal()
		push_str("Do you really want to\nreset the scoreboard?\n\n  ")
		put_button("yes", func():
			scoreboard = []
			save_scoreboard()
			show_settings()
		)
		push_str("    ")
		put_button("no", show_settings)
		push_str("\n")
	)
	if is_paused:
		put_settings_button("return", show_pause_screen)
	else:
		return_to_title_screen_button()

const POSITIVE_MESSAGES := [
	"Keep it up!",
	"GO GO GO!",
	"Nice!",
	"Never Stop!",
	"Oh yeah!",
	"Very good!",
	"You are a superhero!"
]
const NEGATIVE_MESSAGES := [
	"What a bummer",
	"What was that?",
	"Oops",
	"Oh no!",
	"Maybe next time",
	"| ||\n|| |_"  # this is an important meme don't remove!
]

func switch_game_screen(was_successfull: bool) -> void:
	clear_terminal()
	var msg: String = (POSITIVE_MESSAGES if was_successfull else NEGATIVE_MESSAGES).pick_random()
	push_str(msg + "\n\n")
	push_str("Lifes: ")
	push_str("♥".repeat(game_manager.lifes))
	push_str("†".repeat(game_manager.max_lifes - game_manager.lifes))
	push_str("\n")
	push_str("Score: " + str(game_manager.won_games) + "\n")
