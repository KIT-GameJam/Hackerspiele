extends Node3D

const ROTATION_SPEED := 2.5
const MOVEMENT_SPEED := 60.0
const ACCELERATION := 200.0

var current_speed := 0.0

@onready var hand_open = $hand_anchor/hand_open
@onready var hand_grab = $hand_anchor/hand_grab

var current_carrot_id = null
var current_carrot = null
var number_carrots_pulled = 0

signal carrot_pulled
signal show_focus(pos: Vector3)
signal hide_focus

func _physics_process(delta: float) -> void:
	var tilt_dir := Input.get_axis("left", "right")
	rotate(Vector3.UP, -tilt_dir * delta * ROTATION_SPEED)
	var move_forward := Input.get_axis("down", "up")
	var target_speed := move_forward * MOVEMENT_SPEED
	current_speed = move_toward(current_speed, target_speed, ACCELERATION * delta)
	translate(Vector3.FORWARD * current_speed * delta)

	if current_carrot != null:
		hand_open.visible = false
		hand_grab.visible = true
	else:
		hand_open.visible = true
		hand_grab.visible = false

func _process(_delta: float) -> void:
	if current_carrot != null:
		if Input.is_action_just_pressed("submit"):
			if current_carrot.pull_out_carrot():
				current_carrot = null
				current_carrot_id = 0
				carrot_pulled.emit()
				hide_focus.emit()

func carrot_enter(area: Area3D) -> void:
	if area.get_meta("is_carrot"):
		print("carrot entered player")
		var parent = area.get_parent()
		print("this is carrot num # "+ str(parent.get_meta("num")))
		if current_carrot_id == null and not parent.pulled:
			current_carrot_id = parent.get_meta("num")
			current_carrot = parent
			show_focus.emit(Vector3(parent.global_position.x, 1, parent.global_position.z ))
			#parent.get_node("focus").visible = true
		else:
			print("already focussing at another carrot")

func carrot_leave(area: Area3D) -> void:
	if(area.get_meta("is_carrot")):
		current_carrot = null
		current_carrot_id = null
		print("carrot left player")
		var parent = area.get_parent()
		hide_focus.emit()
		print("this was carrot num # "+ str(parent.get_meta("num")))
