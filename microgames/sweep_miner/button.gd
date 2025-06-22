extends Button

@onready var label: Label = $Panel/Label

var bomb_n: int
var has_opened := false

func _process(_delta: float) -> void:
	if has_focus():
		$Panel.modulate = Color("#999999")
	else:
		$Panel.modulate = Color.WHITE

func set_bomb_n(val: int):
	bomb_n = val
	if val:
		label.text = str(val)
	else:
		label.text = ""

func open() -> void:
	has_opened = true
	label.show()
	disabled = true
	focus_mode = Control.FOCUS_NONE
	if bomb_n == 0:
		modulate = Color("#555555")
