extends Sprite2D

@export var plate_with_toast_texture: Texture2D
@export var toast: RigidBody2D
@export var microgame_root : Node

func _on_plate_reached_area_body_entered(_body: Node2D) -> void:
	if (toast.toastedness > 1.0):
		microgame_root._lose()
	else:
		texture = plate_with_toast_texture
		toast.set_deferred("freeze", true)
		toast.visible = false
		microgame_root._win()
