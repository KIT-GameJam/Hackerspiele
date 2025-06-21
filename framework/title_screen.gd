extends Node3D
class_name TitleScreen

@export var PRINT_TIMEOUT: float
@export var TERM_W: int
@export var TERM_H: int

@export var SCOREBOARD_SIZE := 5
var scoreboard := []
const SCOREBOARD_PATH := "user://scoreboard.dat"

const POWEROFF_COLOR_INACTIVE := Color("#cd5424")
const POWEROFF_COLOR_ACTIVE := Color("#ed7444")
const VOLUME_SLIDER_SIZE := 16
const VOLUME_SLIDER_FULL_CHAR := "#"
const VOLUME_SLIDER_EMPTY_CHAR := "-"
const AUDIO_CFG_PATH := "user://audio.cfg"
const VOLUME_SECTION := "volume"
const BOTTLE_SCATTER := 0.3
const BOTTLE_OFFSET := 1.0

@onready var camera: Camera3D = $Camera
@onready var marker_top_left: Marker3D = $Monitor/MarkerTopLeft
@onready var marker_top_right: Marker3D = $Monitor/MarkerTopRight
@onready var marker_bottom_right: Marker3D = $Monitor/MarkerBottomRight
@onready var screen_layer: CanvasLayer = $Monitor/ScreenLayer
@onready var screen: Panel = $Monitor/ScreenLayer/Screen
@onready var label: Label = $Monitor/ScreenLayer/Screen/Label
@onready var cursor_rect: Panel = $Monitor/ScreenLayer/Screen/CursorRect
@onready var logo: Control = $Monitor/ScreenLayer/Screen/Logo
@onready var poweroff_button: MeshInstance3D = $Monitor/PoweroffButton
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var blink_timer: Timer = $Monitor/ScreenLayer/Screen/BlinkTimer
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game-manager")
@onready var line_edit: LineEdit = $Monitor/ScreenLayer/Screen/LineEdit
var print_time := 0.0
var cursor := Vector2i(0, 0)
var print_queue: Array[PrintEvent] = []
var environment_buffer: Environment = null
var is_paused := false
var bottle_offset_left := 0.0
var bottle_offset_right := 0.0
var bottles: Array[MeshInstance3D] = []

var input_buffer := []

enum Direction { LEFT, RIGHT, UP, DOWN }

enum PrintEventType { CHAR, BUTTON, SYNC }

class PrintEvent:
	var ty: PrintEventType
	var val
	var onclick: Callable
	func _init(p_ty: PrintEventType, p_val) -> void:
		self.ty = p_ty
		self.val = p_val

class Sync:
	signal sync

func _ready() -> void:
	load_scoreboard()
	load_audio_settings()
	update_poweroff_button_color(POWEROFF_COLOR_INACTIVE)

	show_title_screen()
	reset_bottles()

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

func _input(event: InputEvent) -> void:
	# easter egg
	const KONAMI: Array[Direction] = [Direction.UP, Direction.UP, Direction.DOWN, Direction.DOWN, Direction.LEFT, Direction.RIGHT, Direction.LEFT, Direction.RIGHT]

	if event.is_action_pressed("left"):
		input_buffer.append(Direction.LEFT)
	elif event.is_action_pressed("right"):
		input_buffer.append(Direction.RIGHT)
	elif event.is_action_pressed("up"):
		input_buffer.append(Direction.UP)
	elif event.is_action_pressed("down"):
		input_buffer.append(Direction.DOWN)
	else:
		return

	var buffer_size := input_buffer.size()
	if buffer_size > KONAMI.size():
		input_buffer = input_buffer.slice(buffer_size - KONAMI.size(), buffer_size)
	if input_buffer == KONAMI:
		if camera.projection != Camera3D.PROJECTION_PERSPECTIVE:
			camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		else:
			camera.projection = Camera3D.PROJECTION_ORTHOGONAL

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
	logo.hide()
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

func push_sync() -> Signal:
	var sync_obj := Sync.new()
	print_queue.append(PrintEvent.new(PrintEventType.SYNC, sync_obj))
	return sync_obj.sync

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
			event.val.sync.emit()

func create_terminal_button(text: String, onclick: Callable) -> Button:
	var button := Button.new()
	var bounds := get_cursor_char_bounds()
	button.position = bounds.position
	button.size = bounds.size * Vector2(text.length(), 1.0)
	button.tooltip_text = text
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if get_viewport().gui_get_focus_owner() == null:
		button.grab_focus.call_deferred()
	button.connect("pressed", func():
		game_manager.beep_sound.play()
		onclick.call()
	)
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

func reset_bottles() -> void:
	bottle_offset_left = 0.0
	bottle_offset_right = 0.0
	for bottle in bottles:
		remove_child(bottle)
		bottle.queue_free()
	bottles = []

func add_bottle() -> void:
	var new_bottle: MeshInstance3D = $Mate.duplicate()
	new_bottle.remove_child(new_bottle.get_child(0))
	var scatter := randf_range(-BOTTLE_SCATTER, BOTTLE_SCATTER)
	if randi_range(0, 1):
		bottle_offset_left -= BOTTLE_OFFSET
		new_bottle.position.x += bottle_offset_left
		new_bottle.position.z += scatter
	else:
		new_bottle.position.x += bottle_offset_right
		bottle_offset_right -= BOTTLE_OFFSET
		new_bottle.position.z -= scatter + 3.16
	new_bottle.rotation_degrees.y += randf_range(-15.0, 15.0)
	add_child(new_bottle)
	bottles.append(new_bottle)

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
		await push_sync()
		line_edit.clear()
		line_edit.show()
		line_edit.grab_focus.call_deferred()
		line_edit.position = label.position + get_cursor_char_bounds().position
		var scoreboard_name = await line_edit.text_submitted
		line_edit.hide()
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


# audio

func change_volume(bus_idx: int, volume_cursor: Vector2i, delta: int):
	var val := clampi(linear_to_slider_volume(AudioServer.get_bus_volume_linear(bus_idx)) + delta, 0, VOLUME_SLIDER_SIZE)
	AudioServer.set_bus_volume_linear(bus_idx, slider_volume_to_linear(val))
	update_volume_graphics(volume_cursor, val)
	save_audio_settings()

func load_audio_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(AUDIO_CFG_PATH)
	if err != OK:
		return
	print("loading audio settings")
	for bus_name in config.get_section_keys(VOLUME_SECTION):
		var value = config.get_value(VOLUME_SECTION, bus_name)
		if value != null:
			var bus_idx := AudioServer.get_bus_index(bus_name)
			AudioServer.set_bus_volume_linear(bus_idx, value)

func save_audio_settings() -> void:
	var config := ConfigFile.new()
	for bus_idx in range(AudioServer.bus_count):
		var bus_name := AudioServer.get_bus_name(bus_idx)
		config.set_value(VOLUME_SECTION, bus_name, AudioServer.get_bus_volume_linear(bus_idx))
	config.save(AUDIO_CFG_PATH)


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
	logo.show()

func return_to_title_screen_button() -> void:
	put_settings_button("return to title screen", show_title_screen)

func return_to_settings_button() -> void:
	put_settings_button("return to settings", show_settings)

func update_volume_graphics(volume_cursor: Vector2i, val: int):
	for i in range(VOLUME_SLIDER_SIZE):
		var chr := VOLUME_SLIDER_FULL_CHAR if i < val else VOLUME_SLIDER_EMPTY_CHAR
		setc(volume_cursor.y, volume_cursor.x + i, chr)

func slider_volume_to_linear(val: int) -> float:
	return float(val) / VOLUME_SLIDER_SIZE

func linear_to_slider_volume(linear: float) -> int:
	return int(roundf(linear * float(VOLUME_SLIDER_SIZE)))

func put_volume_slider(slider_name: String, bus_name: String) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	push_str((slider_name + ":").rpad(8))
	await push_sync()
	var volume_cursor := cursor + Vector2i(3, 0) # the "-" button is 3 chars long
	put_button("-", func():
		change_volume(bus_idx, volume_cursor, -1)
	)
	var volume_bars := linear_to_slider_volume(AudioServer.get_bus_volume_linear(bus_idx))
	await push_sync()
	update_volume_graphics(volume_cursor, volume_bars)
	cursor.x += VOLUME_SLIDER_SIZE
	put_button("+", func():
		change_volume(bus_idx, volume_cursor, 1)
	)
	push_str("\n")

func show_volume_settings() -> void:
	clear_terminal()
	push_str("Volume Settings\n")
	push_str("===============\n\n")
	await put_volume_slider("Master", "Master")
	await put_volume_slider("UI", "Ui")
	await put_volume_slider("Music", "Music")
	await put_volume_slider("Sfx", "Sfx")
	return_to_settings_button()

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
	"You are a superhero!",
]
const NEGATIVE_MESSAGES := [
	"What a bummer",
	"What was that?",
	"Oops",
	"Oh no!",
	"Maybe next time",
	"|  ||\n|| |_",  # this is an important meme, don't remove!
]

func switch_game_screen(was_successfull: bool) -> void:
	clear_terminal()
	var msg: String = (POSITIVE_MESSAGES if was_successfull else NEGATIVE_MESSAGES).pick_random()
	push_str(msg + "\n\n")
	push_str("Lifes: " + str(game_manager.lifes))
	push_str("\n")
	push_str("Score: " + str(game_manager.won_games) + "\n")

func _on_line_edit_text_changed(new_text: String) -> void:
	cursor.x = new_text.length()
	update_cursor_pos()
