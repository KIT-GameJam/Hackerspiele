extends MicroGame

var stone_goal: int
var game_finished: bool = false

var water_tile_map_layer: WaterTileMapLayer

@onready var goal_label: Label = $GoalLabel
@onready var stone_counter: Label = $StoneCounter
@onready var player_cursor: PlayerCursor = $PlayerCursor

func _ready() -> void:
	pick_random_map_layer()
	
	player_cursor.scale = water_tile_map_layer.cell_size / 64 * Vector2.ONE
	
	stone_goal = water_tile_map_layer.stone_goal
	goal_label.text = "Fill level with " + str(stone_goal) + " stones by combining water and lava\nActivate cells to toggle between water and lava sources"

func pick_random_map_layer() -> void:
	var tile_maps := find_children("*", "WaterTileMapLayer")
	water_tile_map_layer = tile_maps.pick_random()
	water_tile_map_layer.visible = true
	water_tile_map_layer.board_changed.connect(_update_goal_status)
	player_cursor.water_tile_map_layer = water_tile_map_layer
	
	for tile_map in tile_maps:
		if tile_map != water_tile_map_layer:
			tile_map.visible = false

func _update_goal_status() -> void:
	if game_finished:
		return

	var stone_count := water_tile_map_layer.count_stone_on_cells()
	stone_counter.text = str(stone_count) + " / " + str(stone_goal)

	if stone_count >= stone_goal:
		game_finished = true
		finished.emit(Result.Win)
