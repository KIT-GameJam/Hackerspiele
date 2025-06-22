class_name PicSlideTile extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
var correct_position: Vector2i
var curr_position: Vector2i

func set_img(texture: CompressedTexture2D):
	sprite.texture = texture
