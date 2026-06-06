class_name PlayerCursor
extends Node2D

const cursor_speed: float = 0.2

var delta_sum: float = 0

var current_cell: Vector2i = Vector2i.ZERO

var water_tile_map_layer: WaterTileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_cell = (global_position / water_tile_map_layer.cell_size).floor()
	
	delta_sum += delta
	if delta_sum > cursor_speed * (water_tile_map_layer.cell_size / 64):
		delta_sum = 0
		_move_player()
	
	if Input.is_action_just_pressed("submit"):
		water_tile_map_layer.cycle_source_at_cell(current_cell)

func _move_player() -> void:
	var player_dir := Input.get_vector("left", "right", "up", "down")
	if player_dir == Vector2.ZERO:
		return
	
	var step_dir := Vector2.ZERO
	if abs(player_dir.x) >= abs(player_dir.y):
		step_dir.x = sign(player_dir.x)
	else:
		step_dir.y = sign(player_dir.y)
	
	var new_pos := global_position + step_dir * water_tile_map_layer.cell_size
	var size := water_tile_map_layer.get_size() * water_tile_map_layer.cell_size
	
	global_position = new_pos.clamp(Vector2.ZERO, size)
