extends MicroGame

@export var W: int 
@export var H: int
@export var bomb_count: int

@onready var grid_node: GridContainer = find_child("GridContainer")

var button_scene: PackedScene = preload("res://microgames/sweep_miner/button.tscn")
var bombs: Array[Vector2i] = []

func _ready() -> void:
	grid_node.columns = W
	find_child("BombCount").text = "{0} Bombs".format([bomb_count])
	for y in range(H):
		for x in range(W):
			var button: Button = button_scene.instantiate()
			if x == (W >> 1) and y == (H >> 1): button.grab_focus.call_deferred()
			button.pressed.connect(func(): on_button(Vector2i(x, y)))
			grid_node.add_child(button)

func get_btn(coord: Vector2i) -> Button:
	if coord.x < 0 or coord.y < 0 or coord.x >= W or coord.y >= H: return null
	return grid_node.get_child(coord.x + coord.y * W)

func gen(skip_coord: Vector2i) -> void:
	while not try_gen(skip_coord): pass

func try_gen(skip_coord: Vector2i) -> bool:
	while bombs.size() < bomb_count:
		var coord := Vector2i(randi_range(0, W - 1), randi_range(0, H - 1))
		for dy in range(-1, 2, 1):
			for dx in range(-1, 2, 1):
				if coord + Vector2i(dx, dy) == skip_coord:
					return false
		if bombs.find(coord) == -1:
			bombs.append(coord)
	for y in range(H):
		for x in range(W):
			var coord = Vector2i(x, y)
			var btn := get_btn(coord)
			var n := 0
			if bombs.find(coord) != -1:
				n = -1
			else:
				for dy in range(-1, 2, 1):
					for dx in range(-1, 2, 1):
						if bombs.find(coord + Vector2i(dx, dy)) != -1:
							n += 1
			btn.set_bomb_n(n)
	return true

func open_button(coord: Vector2i) -> void:
	get_btn(coord).open()
	var found_btn: Button = null
	var found_btn_coord: Vector2
	for y in range(H):
		for x in range(W):
			var new_coord := Vector2i(x, y)
			var new_btn := get_btn(new_coord)
			if new_btn.has_opened: continue
			if found_btn == null:
				found_btn = new_btn
				found_btn_coord = new_coord
			elif new_coord.distance_squared_to(coord) < found_btn_coord.distance_squared_to(coord):
				found_btn = new_btn
				found_btn_coord = new_coord
	if found_btn:
		found_btn.grab_focus.call_deferred()

func open_button_rec(coord: Vector2i) -> void:
	open_button(coord)
	for dy in range(-1, 2, 1):
		for dx in range(-1, 2, 1):
			var d := Vector2i(dx, dy)
			var nei := get_btn(coord + d)
			if nei == null: continue
			if not nei.has_opened:
				if nei.bomb_n == 0:
					open_button_rec(coord + d)
				else:
					open_button(coord + d)

func on_button(coord: Vector2i) -> void:
	if not bombs:
		gen(coord)
	if bombs.find(coord) != -1:
		finished.emit(Result.Loss)
		return
	var btn := get_btn(coord)
	if btn.bomb_n == 0:
		open_button_rec(coord)
	else:
		open_button(coord)
	for y in range(H):
		for x in range(W):
			if not get_btn(Vector2i(x, y)).has_opened and bombs.find(Vector2i(x, y)) == -1: return
	finished.emit(Result.Win)
