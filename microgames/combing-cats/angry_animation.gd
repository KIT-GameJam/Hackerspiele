extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_main_cat_calm() -> void:
	hide() # Replace with function body.


func _on_main_cat_angry() -> void:
	show() # Replace with function body.
