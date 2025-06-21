extends Timer

func _ready():
	await get_tree().create_timer(randf()).timeout
	start()
