extends Node3D

var grass_scene = preload("res://microgames/gardening/assets/grass_blade.tscn")
var LEVEL_SIZE := 100

func spawn_grass():
	print("spawning grass")
	for n in 15000:
		var grass : Node3D = grass_scene.instantiate()
		grass.set_name("grass" + str(n))
		var posx = randf() * 2.0 - 1.0
		var posy = randf() * 2.0 - 1.0
		grass.set_position(Vector3(posx * LEVEL_SIZE, 0, posy * LEVEL_SIZE))
		grass.set_rotation(Vector3(0.0, randf() * 2 * PI, 0.0))
		var size = remap(randf(), 0.0, 1.0, 0.4, 0.7)
		grass.set_scale(Vector3(size * 0.7,size,size * 0.7))
	#grass.position = Vector3(10.0, 1, 11.0)
		add_child(grass)
	
