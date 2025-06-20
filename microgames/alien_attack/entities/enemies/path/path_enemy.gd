class_name AlienAttackPathEnemy extends Path2D

@export var speed := 0.25
@onready var path_follow := $PathFollow2D
@onready var enemy := $PathFollow2D/Enemy

func _ready():
	path_follow.set_progress_ratio(1)

func _physics_process(delta):
	path_follow.progress_ratio -= speed * delta
	if path_follow.progress_ratio == 0:
		queue_free()
