class_name MartianMikeLevel extends Node2D

@export var level_time := 20
@onready var start := $Start
@onready var exit := $Exit
@onready var deathzone := $Deathzone
const player_scene = preload("res://microgames/martian_mike/entities/player/player.tscn")
var player: MartianMikePlayer = null
signal win

func _ready():
	var traps := get_tree().get_nodes_in_group("traps")
	for trap: Trap in traps:
		trap.touched_player.connect(_on_trap_touched_player)

	player = player_scene.instantiate()
	reset_player(player)
	add_child(player)
	exit.body_entered.connect(_on_exit_player_entered)
	deathzone.body_entered.connect(_on_deathzone_player_entered)

func reset_player(_player: MartianMikePlayer):
	_player.velocity = Vector2.ZERO
	_player.global_position = start.get_spawn_pos()

func reset_level():
	reset_player(player)
	player.on_player_hurt()

func _on_deathzone_player_entered(_player: MartianMikePlayer):
	reset_level()

func _on_trap_touched_player(_player: MartianMikePlayer):
	reset_level()

func _on_exit_player_entered(_player: MartianMikePlayer):
	win.emit()
	
