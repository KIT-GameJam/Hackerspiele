extends Sprite2D

func _ready() -> void:
	$BaseGrid.visible = true
	$Border.visible = false
	
func select(value):
	$BaseGrid.visible = !value

func showBorder(value):
	$Border.visible = value
