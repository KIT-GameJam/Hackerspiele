extends MicroGame

@export var num_obstacles = 200
@export var num_bushes = 140
const tree_scene = preload("res://microgames/skiing/entities/obstacle/tree/tree.tscn")
const bush_scene = preload("res://microgames/skiing/entities/obstacle/bush/bush.tscn")
@onready var obstacles_container := $Obstacles

func _ready() -> void:
	for i in range(num_obstacles):
		var random_pos := Vector3(randf_range(-40.0, 40.0), 0.0, randf_range(-90.0, -15.0))
		if num_bushes > 0:
			_place_obstacle(bush_scene, random_pos)
			num_bushes -= 1
		else:
			_place_obstacle(tree_scene, random_pos)

func _on_goal_player_entered(_player: Player) -> void:
	finished.emit(Result.Win)

func _place_obstacle(scene: Resource, pos: Vector3):
	var obstacle = scene.instantiate()
	obstacle.position = pos
	obstacles_container.add_child(obstacle)
