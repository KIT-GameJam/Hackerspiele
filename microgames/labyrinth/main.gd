extends MicroGame

@export_range(0, 100, 2) var maze_size := 16
@export var move_time := 0.1

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D
var colours: Dictionary[String, Vector2i]
var player_pos := Vector2i(5, 5)
var player_colour: Vector2i
var wall_colour: Vector2i
var exit_colour: Vector2i

func _ready() -> void:
	# initialize colours
	var source: TileSetAtlasSource = tile_map.tile_set.get_source(0)
	for i in range(source.get_tiles_count()):
		var id := source.get_tile_id(i)
		var colour: String = source.get_tile_data(id, 0).get_custom_data("colour")
		colours[colour] = id

	# choose colours
	player_colour = colours.red
	wall_colour = colours.white
	exit_colour = colours.orange

	var maze_bounds := Rect2i(player_pos, Vector2i(maze_size, maze_size))
	generate_maze(maze_bounds)
	tile_map.set_cell(player_pos, 0, player_colour)
	tile_map.set_cell(maze_bounds.end - Vector2i(2, 2), 0, exit_colour)

	# move camera
	camera.position = tile_map.map_to_local(maze_bounds.get_center())

func _input(event: InputEvent) -> void:
	var direction: Vector2i
	if event.is_action_pressed("up"):
		direction = Vector2i.UP
	elif event.is_action_pressed("down"):
		direction = Vector2i.DOWN
	elif event.is_action_pressed("left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed("right"):
		direction = Vector2i.RIGHT
	move_player(direction)
	await get_tree().create_timer(move_time).timeout
	move_player(direction)

func move_player(direction: Vector2i) -> void:
	tile_map.set_cell(player_pos)
	var new_pos := player_pos + direction
	var atlas_coords := tile_map.get_cell_atlas_coords(new_pos)
	if atlas_coords == Vector2i(-1, -1):
		# new_pos is empty
		player_pos = new_pos
	elif atlas_coords == exit_colour:
		player_pos = new_pos
		finished.emit(Result.Win)
	tile_map.set_cell(player_pos, 0, colours.red)

func generate_maze(bounds: Rect2i):
	# set bounds rectangle to wall_colour
	for i in range(-1, bounds.size.x):
		for j in range(-1, bounds.size.y):
			var coords := bounds.position + Vector2i(i, j)
			tile_map.set_cell(coords, 0, wall_colour)

	# generate starting point
	var x := randi_range(0, (bounds.size.x - 1) / 2)
	var y := randi_range(0, (bounds.size.y - 1) / 2)
	var start := bounds.position + 2 * Vector2i(x, y)

	# randomized DFS
	tile_map.set_cell(start)
	var stack := [start]
	var visited := {start: null}
	var directions: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	while not stack.is_empty():
		var cell: Vector2i = stack.pop_back()
		directions.shuffle()
		for direction in directions:
			var new_cell := cell + 2 * direction
			if bounds.has_point(new_cell) and not new_cell in visited:
				stack.push_back(cell)
				tile_map.set_cell(cell + direction)
				tile_map.set_cell(new_cell)
				visited[new_cell] = null
				stack.push_back(new_cell)
				break
