class_name Cup
extends Node3D

@export_range(0.0, 1.0, 0.01) var outline_thickness := 0.05

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func outline(enable: bool) -> void:
	var thickness := outline_thickness if enable else 0.0
	mesh_instance.mesh.material.next_pass.set_shader_parameter("thickness", thickness)
