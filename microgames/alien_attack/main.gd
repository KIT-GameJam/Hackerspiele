extends MicroGame

@onready var player := $Player
@onready var enemy_hit_sound := $EnemyHitSound
@onready var player_took_damage_sound := $PlayerTookDamageSound
@onready var alien_container := $Aliens

func on_timeout():
	return Result.Win

func _on_enemy_entered_deathzone(_enemy: Area2D):
	finished.emit(Result.Loss)

func _on_player_took_damage():
	finished.emit(Result.Loss)

func _on_enemy_died(): 
	enemy_hit_sound.play()

func _on_enemy_spawned(enemy: AlienAttackEnemy):
	alien_container.add_child(enemy)
	enemy.connect("died", _on_enemy_died)

func _on_path_enemy_spawned(path_enemy: AlienAttackPathEnemy):
	alien_container.add_child(path_enemy)
	path_enemy.enemy.connect("died", _on_enemy_died)
