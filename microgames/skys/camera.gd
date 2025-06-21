extends Camera2D

@onready var player := $"../PlayerBody"
var reparented : bool = false

func _process(delta: float) -> void:
	if player.position.x >= 0 and not reparented:
		reparented = true
		reparent(player)
