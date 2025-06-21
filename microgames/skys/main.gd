extends MicroGame


#var distances = PackedFloat32Array()
#var obstacles = []
var obstacle_offsets = []
var next_obstacle_i = 0
var n_obstacles = 200
var obstacleScene =  load("res://microgames/skys/obstacle.tscn")
const PHYSICS_SCALE = 45 # approx ~ pix/m
@onready var player := $PlayerBody
@onready var game_manager : GameManager = get_tree().get_first_node_in_group("game-manager")
@onready var distance_to_finish : float = player.base_speed * game_manager.timer.wait_time; # in m
@onready var finish_position : float = player.position.x + PHYSICS_SCALE * distance_to_finish;


func _ready() -> void:
	#finished.emit(Result.Win)
	player.hit_registered.connect(_on_hit_registered)
	
	# Place goal strip:
	$Goal.position.x = finish_position
	
	# TODO: sample random distances, finite array?
	# sample new distance after every step
	#var rng = RandomNumberGenerator.new()
	var offset = 0;
	for i in range(n_obstacles):
		var d = PHYSICS_SCALE * randf_range(5, 30)
		#distances[i] = d
		offset += d
		if offset >= finish_position:
			break
		obstacle_offsets.append(offset)
	obstacle_offsets.append(INF) # hack:Q next obstacle after, the "last" obstacle is at infinity

		
		#add_child_below_node(get_tree().get_root().get_node("Game"),ob)

		#add_child_below_node($Main, ob)
	#$ObstacleBody.duplicate().set_
	#var bullet = projectile.instance()
	
func _process(delta: float) -> void:
	var place_obstacle_ahead_distance = 1280 / 2 * 1.5
	# while loop, in case we are very fast... i.e. moving faster than mindist/delta 
	while obstacle_offsets[next_obstacle_i] - player.position.x <= place_obstacle_ahead_distance:
		var size = randf_range(0.5, 3.)
		var spawn_height = -500 #-6 * PHYSICS_SCALE # m * pix/m
		place_obstacle(obstacle_offsets[next_obstacle_i], size, spawn_height)
		next_obstacle_i += 1

func place_obstacle(offset, size, height):
	var ob : SkyObstacle = obstacleScene.instantiate()
	ob.set_height(size)
	# ouch, mixing size units :(
	ob.set_position(Vector2(offset, height + size * PHYSICS_SCALE))
	add_child(ob)
	return ob
		
func on_timeout():
	return Result.Win
	
func _on_hit_registered():
	print_debug("hit in main")
	finished.emit(Result.Loss)
	
