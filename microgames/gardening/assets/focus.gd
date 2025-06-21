extends Node3D

@export var rotation_speed: float = 45.0 # degrees per second

var time_spawn: float = 0.0
var spawned: bool = false

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(rotation_speed * delta))
	
	if not spawned:
		time_spawn += delta
		if time_spawn >= 0.2:
			visible = false
			spawned = true

func show_effect(global_pos: Vector3) -> void:
	global_position = global_pos
	visible = true
	
func hide_effect() -> void:
	visible = false
