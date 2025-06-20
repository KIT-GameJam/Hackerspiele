extends MicroGame

#var distances = PackedFloat32Array()
var obstacles = []
var n_obstacles = 1000
var obstacleScene =  load("res://microgames/skys/obstacle.tscn")

func _ready() -> void:
	finished.emit(Result.Win)
	# TODO: sample random distances, finite array?
	# sample new distance after every step
	#var rng = RandomNumberGenerator.new()
	var offset = 0;
	for i in range(n_obstacles):
		var d = randf_range(5, 30)
		#distances[i] = d
		offset += d
		var ob = obstacleScene.instantiate()
		obstacles.append(ob)
		ob.set_position(Vector2(offset, -10))
		#add_child_below_node(get_tree().get_root().get_node("Game"),ob)
		add_child(ob)
		#add_child_below_node($Main, ob)
	#$ObstacleBody.duplicate().set_
	#var bullet = projectile.instance()
	
	
	
