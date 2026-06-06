class_name WaterTileMapLayer
extends TileMapLayer

@onready var simulation_timer: Timer = $"../SimulationTimer"
signal board_changed

const NOTHING: Vector2i = -Vector2i.ONE
const WATER_ATLAS_TOP: Vector2i = Vector2i(12, 10)
const WATER_ATLAS: Vector2i = Vector2i(12, 11)
const WATER_SOURCE_ATLAS: Vector2i = Vector2i(18, 9)
const LAVA_ATLAS_TOP: Vector2i = Vector2i(14, 10)
const LAVA_ATLAS: Vector2i = Vector2i(14, 11)
const LAVA_SOURCE_ATLAS: Vector2i = Vector2i(18, 8)
const STONE: Vector2i = Vector2i(0, 1)

const SOURCE_ID: int = 1

const enable_log: bool = false

enum FluidType {
	WATER,
	LAVA,
}

var cell_size: float = 64

@export var simulation_speed: float = 2

@export var stone_goal: int = 25

func _ready() -> void:
	_update_fluid_visuals()
	
	cell_size = cell_size * scale.x
	
	simulation_timer.wait_time = (1 / scale.x) / simulation_speed
	simulation_timer.timeout.connect(_simulate_step)

func _simulate_step() -> void:
	_simulate_fluid(FluidType.WATER)
	_simulate_fluid(FluidType.LAVA)
	_spawn_from_sources()
	_update_fluid_visuals()
	board_changed.emit()

func _spawn_from_sources() -> void:
	for source_cell in get_used_cells_by_id(SOURCE_ID, WATER_SOURCE_ATLAS):
		_spawn_from_source(source_cell, FluidType.WATER)
	for source_cell in get_used_cells_by_id(SOURCE_ID, LAVA_SOURCE_ATLAS):
		_spawn_from_source(source_cell, FluidType.LAVA)

func _spawn_from_source(source_cell: Vector2i, fluid_type: FluidType) -> void:
	var below_cell := source_cell + Vector2i.DOWN
	_try_create_fluid_in_cell(below_cell, fluid_type)

func _try_create_fluid_in_cell(target_cell: Vector2i, fluid_type: FluidType) -> void:
	if _is_cell_empty(target_cell):
		set_cell(target_cell, SOURCE_ID, _fluid_body_atlas(fluid_type))
	elif _is_cell_opposite(target_cell, fluid_type):
		set_cell(target_cell, SOURCE_ID, STONE)

func _simulate_fluid(fluid_type: FluidType) -> void:
	var fluid_cells := _get_fluid_cells(fluid_type)
	fluid_cells.sort_custom(func(a, b): return a.y > b.y)

	if enable_log:
		print("-------------------")
		print("simulate fluid, " + str(len(fluid_cells)) + " cells: " + str(fluid_cells))

	for cell in fluid_cells:
		if not _is_fluid_cell(cell, fluid_type):
			continue

		var below_cell := cell + Vector2i.DOWN
		if _try_move_fluid(cell, below_cell, fluid_type):
			continue

		if _is_same_fluid_or_source(below_cell, fluid_type):
			var empty_bottom_row_cell = _find_empty_cell_in_row(below_cell, fluid_type)
			if empty_bottom_row_cell != null and _try_move_fluid(cell, empty_bottom_row_cell, fluid_type):
				continue

		var bottom_right_cell := below_cell + Vector2i.RIGHT
		var bottom_left_cell := below_cell + Vector2i.LEFT
		var right_cell := cell + Vector2i.RIGHT
		var left_cell := cell + Vector2i.LEFT

		if _is_cell_empty(right_cell) and not _is_cell_blocking(bottom_right_cell):
			_try_move_fluid(cell, right_cell, fluid_type)
		elif _is_cell_empty(left_cell) and not _is_cell_blocking(bottom_left_cell):
			_try_move_fluid(cell, left_cell, fluid_type)

func _try_move_fluid(from_cell: Vector2i, to_cell: Vector2i, fluid_type: FluidType) -> bool:
	if _is_cell_empty(to_cell):
		set_cell(to_cell, SOURCE_ID, _fluid_body_atlas(fluid_type))
		set_cell(from_cell)
		return true

	if _is_cell_opposite(to_cell, fluid_type):
		set_cell(to_cell, SOURCE_ID, STONE)
		set_cell(from_cell)
		return true

	return false

func _get_fluid_cells(fluid_type: FluidType) -> Array[Vector2i]:
	if fluid_type == FluidType.WATER:
		return get_used_cells_by_id(SOURCE_ID, WATER_ATLAS_TOP) + get_used_cells_by_id(SOURCE_ID, WATER_ATLAS)
	return get_used_cells_by_id(SOURCE_ID, LAVA_ATLAS_TOP) + get_used_cells_by_id(SOURCE_ID, LAVA_ATLAS)

func _fluid_body_atlas(fluid_type: FluidType) -> Vector2i:
	if fluid_type == FluidType.WATER:
		return WATER_ATLAS
	return LAVA_ATLAS

func _source_atlas(fluid_type: FluidType) -> Vector2i:
	if fluid_type == FluidType.WATER:
		return WATER_SOURCE_ATLAS
	return LAVA_SOURCE_ATLAS

func _is_cell_empty(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == NOTHING

func _is_water_fluid(cell: Vector2i) -> bool:
	var atlas_coords := get_cell_atlas_coords(cell)
	return atlas_coords == WATER_ATLAS_TOP or atlas_coords == WATER_ATLAS

func _is_lava_fluid(cell: Vector2i) -> bool:
	var atlas_coords := get_cell_atlas_coords(cell)
	return atlas_coords == LAVA_ATLAS_TOP or atlas_coords == LAVA_ATLAS

func _is_water_source(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == WATER_SOURCE_ATLAS

func _is_lava_source(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == LAVA_SOURCE_ATLAS

func _is_fluid_cell(cell: Vector2i, fluid_type: FluidType) -> bool:
	if fluid_type == FluidType.WATER:
		return _is_water_fluid(cell)
	return _is_lava_fluid(cell)

func _is_same_fluid_or_source(cell: Vector2i, fluid_type: FluidType) -> bool:
	if fluid_type == FluidType.WATER:
		return _is_water_fluid(cell) or _is_water_source(cell)
	return _is_lava_fluid(cell) or _is_lava_source(cell)

func _is_cell_opposite(cell: Vector2i, fluid_type: FluidType) -> bool:
	if fluid_type == FluidType.WATER:
		return _is_lava_fluid(cell) or _is_lava_source(cell)
	else:
		return _is_water_fluid(cell) or _is_water_source(cell)

func _is_cell_blocking(cell: Vector2i) -> bool:
	var atlas_coords := get_cell_atlas_coords(cell)
	return atlas_coords != NOTHING and not _is_water_fluid(cell) and not _is_lava_fluid(cell) and not _is_water_source(cell) and not _is_lava_source(cell)

func _is_cell_stone(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == STONE

func cycle_source_at_cell(cell: Vector2i) -> bool:
	var atlas_coords := get_cell_atlas_coords(cell)

	if atlas_coords == STONE or _is_water_fluid(cell) or _is_lava_fluid(cell):
		return false

	if atlas_coords == WATER_SOURCE_ATLAS:
		set_cell(cell, SOURCE_ID, LAVA_SOURCE_ATLAS)
	elif atlas_coords == LAVA_SOURCE_ATLAS:
		set_cell(cell)
	elif atlas_coords == NOTHING:
		set_cell(cell, SOURCE_ID, WATER_SOURCE_ATLAS)
	else:
		return false

	_update_fluid_visuals()
	board_changed.emit()
	return true

func create_fluid_spawner(cell: Vector2i, fluid_type: FluidType) -> void:
	if not _is_cell_empty(cell):
		return

	if fluid_type == FluidType.WATER:
		set_cell(cell, SOURCE_ID, WATER_SOURCE_ATLAS)
	elif fluid_type == FluidType.LAVA:
		set_cell(cell, SOURCE_ID, LAVA_SOURCE_ATLAS)

func count_stone_on_cells() -> int:
	var count := 0
	for cell in get_used_cells_by_id(SOURCE_ID, STONE):
		if _is_cell_stone(cell):
			count += 1
	return count

func _update_fluid_visuals() -> void:
	var water_cells := get_used_cells_by_id(SOURCE_ID, WATER_ATLAS_TOP) + get_used_cells_by_id(SOURCE_ID, WATER_ATLAS)
	for cell in water_cells:
		var above_cell := cell + Vector2i.UP
		if _is_cell_empty(above_cell):
			set_cell(cell, SOURCE_ID, WATER_ATLAS_TOP)
		else:
			set_cell(cell, SOURCE_ID, WATER_ATLAS)

	var lava_cells := get_used_cells_by_id(SOURCE_ID, LAVA_ATLAS_TOP) + get_used_cells_by_id(SOURCE_ID, LAVA_ATLAS)
	for cell in lava_cells:
		var above_cell := cell + Vector2i.UP
		if _is_cell_empty(above_cell):
			set_cell(cell, SOURCE_ID, LAVA_ATLAS_TOP)
		else:
			set_cell(cell, SOURCE_ID, LAVA_ATLAS)

func _find_empty_cell_in_row(start_cell: Vector2i, fluid_type: FluidType):
	var used_rect := get_used_rect()
	var min_x := used_rect.position.x
	var max_x := used_rect.position.x + used_rect.size.x - 1
	var max_offset := maxi(start_cell.x - min_x, max_x - start_cell.x)
	var right_blocked := false
	var left_blocked := false

	for offset in range(1, max_offset + 1):
		if not right_blocked:
			var right_cell := start_cell + Vector2i(offset, 0)
			if right_cell.x > max_x:
				right_blocked = true
			elif _is_cell_empty(right_cell):
				return right_cell
			elif not _is_same_fluid_or_source(right_cell, fluid_type):
				right_blocked = true

		if not left_blocked:
			var left_cell := start_cell + Vector2i(-offset, 0)
			if left_cell.x < min_x:
				left_blocked = true
			elif _is_cell_empty(left_cell):
				return left_cell
			elif not _is_same_fluid_or_source(left_cell, fluid_type):
				left_blocked = true

		if right_blocked and left_blocked:
			return null

	return null

func get_size() -> Vector2i:
	var size := get_viewport_rect().size
	
	# Make sure the viewport size is a multiple of the cell size
	size.x -= fmod(size.x, cell_size)
	size.y -= fmod(size.y, cell_size)
	
	# Remove last cell to prevent the cursor from going out of bounds
	size -= Vector2.ONE * cell_size
	
	return size / cell_size
