extends RigidBody3D

signal popped
@export var init_speed := 3
@export var hits_to_pop := 3
@export var down_scale_per_pop := 0.8
@export var speed_inc_per_pop := 1.3
@onready var motion := Vector3(randf_range(-1, 1), randf_range(-1, 1), 0.0).normalized() * 3
@onready var label := $Model/Label3D

func _ready() -> void:
	_update_label()

func _physics_process(_delta: float) -> void:
	position.z = 0.0
	var collision = move_and_collide(motion * _delta)
	if collision:
		motion = motion.bounce(collision.get_normal())

func _on_hitbox_body_entered(body: Node3D) -> void:
	body.queue_free()
	scale *= down_scale_per_pop
	motion *= speed_inc_per_pop
	hits_to_pop -= 1
	_update_label()
	if hits_to_pop == 0:
		popped.emit()
		queue_free()

func _update_label():
	label.text = str(hits_to_pop)
