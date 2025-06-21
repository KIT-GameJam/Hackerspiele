extends MicroGame


#var distances = PackedFloat32Array()
var obstacles = []
var n_obstacles = 200
var obstacleScene =  load("res://microgames/skys/obstacle.tscn")
const PHYSICS_SCALE = 45 # approx ~ pix/m
@onready var player := $PlayerBody

func _ready() -> void:
	#finished.emit(Result.Win)
	player.hit_registered.connect(_on_hit_registered)
	
	
	# TODO: sample random distances, finite array?
	# sample new distance after every step
	#var rng = RandomNumberGenerator.new()
	var offset = 0;
	for i in range(n_obstacles):
		var d = PHYSICS_SCALE * randf_range(5, 30)
		var h = randf_range(0.5, 3.)
		#distances[i] = d
		offset += d
		var ob : SkyObstacle = obstacleScene.instantiate()
		#ob.set_scale(Vector2(1., h))
		ob.set_height(h)
		#ob.get_child(0).scale.y = 1.2
		obstacles.append(ob)
		ob.set_position(Vector2(offset, -10))
		#add_child_below_node(get_tree().get_root().get_node("Game"),ob)
		add_child(ob)
		#add_child_below_node($Main, ob)
	#$ObstacleBody.duplicate().set_
	#var bullet = projectile.instance()
	
func on_timeout():
	return Result.Win
	
func _on_hit_registered():
	print_debug("hit in main")
	finished.emit(Result.Loss)
	
