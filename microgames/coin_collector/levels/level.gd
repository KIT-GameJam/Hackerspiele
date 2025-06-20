extends Node2D

signal win

@onready var player := $Player
@onready var coin_container := $Coins
var coins

func _ready() -> void:
	var coin_scenes: Array[Node] = coin_container.get_children()
	for coin: Area2D in coin_scenes:
		coin.body_entered.connect(on_coin_collected)
	coins = coin_container.get_children().size()

func on_coin_collected(_body):
	player.on_coin_collected()
	coins -= 1
	if (coins == 0):
		win.emit()
