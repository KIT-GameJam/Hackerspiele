extends MicroGame

const tile_scene := preload("res://microgames/pic_slide/entities/tile.tscn")

@onready var tile_container = $Tiles
@onready var tile_positions = [
	{ "pos": $"Background/Frame/01/Marker".global_position, "idx": Vector2i(0, 1) },
	{ "pos": $"Background/Frame/02/Marker".global_position, "idx": Vector2i(0, 2) },
	{ "pos": $"Background/Frame/10/Marker".global_position, "idx": Vector2i(1, 0) },
	{ "pos": $"Background/Frame/00/Marker".global_position, "idx": Vector2i(0, 0) },
	{ "pos": $"Background/Frame/11/Marker".global_position, "idx": Vector2i(1, 1) },
	{ "pos": $"Background/Frame/12/Marker".global_position, "idx": Vector2i(1, 2) },
	{ "pos": $"Background/Frame/20/Marker".global_position, "idx": Vector2i(2, 0) },
	{ "pos": $"Background/Frame/21/Marker".global_position, "idx": Vector2i(2, 1) },
	{ "pos": $"Background/Frame/22/Marker".global_position, "idx": Vector2i(2, 2) },
]

@onready var pictures = [
	"godot"
]

var tiles: Array[PicSlideTile] = []
var free_tile_slot: Vector2i

func _ready():
	tile_positions.shuffle()
	var skip_random = randi_range(0, 8)
	var idx = -1
	for i in range(0, 3):
		for j in range(0, 3):
			idx += 1
			var tile_pos = tile_positions[idx]
			if idx == skip_random:
				free_tile_slot = tile_positions[idx].idx
				
				print(free_tile_slot)
				continue
			var tile: PicSlideTile = tile_scene.instantiate()
			tile.global_position = tile_pos.pos
			tile_container.add_child(tile)
			tile.correct_position = Vector2i(i, j)
			tile.curr_position = tile_pos.idx
			var tile_sprite_path = "res://microgames/pic_slide/assets/" + pictures.pick_random() + "/" + str(i) + str(j) + ".png"
			var tile_sprite = load(tile_sprite_path)
			tile.set_img(tile_sprite)
			tiles.append(tile)

func _process(delta: float) -> void:
	var input_dir: Vector2i
	if Input.is_action_just_pressed("left"):
		input_dir = Vector2i(0, -1)
	elif Input.is_action_just_pressed("right"):
		input_dir = Vector2i(0, 1)
	elif Input.is_action_just_pressed("up"):
		input_dir = Vector2i(-1, 0)
	elif Input.is_action_just_pressed("down"):
		input_dir = Vector2i(1, 0)
	else:
		return
	var tile_pos_to_move = get_pos_tile_to_move(input_dir)
	if not is_in_bounce(tile_pos_to_move):
		return
	
	var tile_to_move = get_tile_from_pos(tile_pos_to_move)
	tile_to_move.curr_position = free_tile_slot
	tile_to_move.position = get_global_pos_from_idx_pos(free_tile_slot)
	free_tile_slot = tile_pos_to_move
	
	if are_tiles_pos_correct():
		finished.emit(Result.Win)

func get_global_pos_from_idx_pos(pos: Vector2i) -> Vector2:
	for tile_pos in tile_positions:
		if tile_pos.idx == pos:
			return tile_pos.pos
	return Vector2.ZERO

func get_tile_from_pos(pos: Vector2i) -> PicSlideTile:
	for tile in tiles:
		if tile.curr_position == pos:
			return tile
	return null

func get_pos_tile_to_move(input_dir: Vector2i):
	return free_tile_slot + (input_dir * -1)

func are_tiles_pos_correct() -> bool:
	for tile in tiles:
		if tile.curr_position != tile.correct_position:
			return false
	return true

func is_in_bounce(pos: Vector2i) -> bool:
	return not (pos.x < 0 or pos.x > 2 or pos.y < 0 or pos.y > 2)
