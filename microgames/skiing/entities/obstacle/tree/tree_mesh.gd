extends Node3D

func _ready() -> void:
	var golden_child:Node3D = get_child(randi() % get_children().size())
	golden_child.visible = true
	golden_child.rotate_y(randf() * 20)
	for bad_child: Node in get_children().filter(func (child): return child != golden_child):
		bad_child.queue_free()
