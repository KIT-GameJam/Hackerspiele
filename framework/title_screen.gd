extends Node3D

@export var BLINK_SPEED: float

@onready var camera: Camera3D = $Camera
@onready var marker_top_left: Marker3D = $Monitor/MarkerTopLeft
@onready var marker_top_right: Marker3D = $Monitor/MarkerTopRight
@onready var marker_bottom_right: Marker3D = $Monitor/MarkerBottomRight
@onready var screen_layer: CanvasLayer = $Monitor/ScreenLayer
@onready var screen: Panel = $Monitor/ScreenLayer/Screen
@onready var cursor: Panel = $Monitor/ScreenLayer/Screen/Cursor
var blink_time := 0.0

func _process(delta: float) -> void:
	while blink_time <= 0.0:
		blink_time += BLINK_SPEED
		cursor.visible = not cursor.visible
	blink_time -= delta
	update_screen_pos()

func update_screen_pos() -> void:
	var top_left = camera.unproject_position(marker_top_left.global_position)
	var top_right = camera.unproject_position(marker_top_right.global_position)
	var bottom_right = camera.unproject_position(marker_bottom_right.global_position)
	var x_axis: Vector2 = top_right - top_left
	var y_axis: Vector2 = bottom_right - top_right
	var scale_x := 1.0 / screen.size.x
	var scale_y := 1.0 / screen.size.y
	screen_layer.transform = Transform2D(x_axis * scale_x, y_axis * scale_y, top_left)
