extends Node3D

var scene_carrot = preload("res://microgames/gardening/assets/carrot.tscn")
var LEVEL_SIZE := 90

func _ready() -> void:	
	for n in 5:
		var carrot : Node3D = scene_carrot.instantiate()
		carrot.set_name("carrot#" + str(n))
		carrot.max_pulls = randi_range(5,10)
		var dir1 = -1.0 if randf() > 0.5 else 1.0
		var dir2 = -1.0 if randf() > 0.5 else 1.0
		var posx = remap(randf(), 0.0, 1.0, 0.2, 1.0) * dir1		
		var posy = remap(randf(), 0.0, 1.0, 0.2, 1.0) * dir2
		carrot.set_position(Vector3(posx * LEVEL_SIZE, -5, posy * LEVEL_SIZE))
		carrot.set_rotation(Vector3(0.0, randf() * 2 * PI, 0.0))
		carrot.get_node("area").set_meta("is_carrot", true)
		carrot.set_meta("num", n)
		add_child(carrot)

func initial_hide_carrot_focus() -> void:
	# needed because the focus effect mesh needs to be on GPU first, to not
	# lag when player encounters first carrot
	for carrot in self.get_children():
		var focus = carrot.has_node("focus")
		print(carrot.name + str(focus))
		var child_focus = carrot.get_node_or_null("focus")
		if child_focus != null:
			child_focus.visible = false
