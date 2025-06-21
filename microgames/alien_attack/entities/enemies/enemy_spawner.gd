extends Node2D

@onready var spawn_positions := $SpawnPositions.get_children()
const enemy_scene := preload("res://microgames/alien_attack/entities/enemies/enemy.tscn")
const path_enemy_scenes := [
	preload("res://microgames/alien_attack/entities/enemies/path/path_enemy0.tscn"),
	preload("res://microgames/alien_attack/entities/enemies/path/path_enemy1.tscn"),
	preload("res://microgames/alien_attack/entities/enemies/path/path_enemy2.tscn"),
	preload("res://microgames/alien_attack/entities/enemies/path/path_enemy3.tscn"),
]

signal enemy_spawned(enemy_instance: AlienAttackEnemy)
signal path_enemy_spawned(path_enemy_instance: AlienAttackPathEnemy)

func spawn_enemy():
	var random_spawn_position: Marker2D = spawn_positions.pick_random()
	var enemy := enemy_scene.instantiate()
	enemy.global_position = random_spawn_position.global_position
	emit_signal("enemy_spawned", enemy)

func spawn_path_enemy():
	var path_enemy = path_enemy_scenes.pick_random().instantiate()
	emit_signal("path_enemy_spawned", path_enemy)

func _on_enemy_spawn_timeout():
	spawn_enemy()

func _on_path_enemy_spawn_timeout():
	spawn_path_enemy()
