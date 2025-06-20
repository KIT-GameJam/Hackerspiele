extends Sprite2D

@export var plate_with_toast_texture: Texture2D
@export var toast: RigidBody2D
@export var microgame_root : Node

func _on_plate_reached_area_body_entered(body: Node2D) -> void:
	texture = plate_with_toast_texture
	toast.freeze = true
	toast.visible = false
	microgame_root._win()
