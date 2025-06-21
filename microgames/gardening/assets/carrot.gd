extends Node3D

var pull_count = 0
var max_pulls = 0
var base_rotation: Vector3
var base_position: Vector3
var tween: Tween
@export var wiggle_angle_deg: float = 12.0
@export var wiggle_offset: float = 0.8
@export var wiggle_duration: float = 0.1
var animation_time_end : float = 1.0
enum ANIM_CARROT {IDLE, WIGGLE, PULLOUT}
var state: ANIM_CARROT = ANIM_CARROT.IDLE
var time: float = 0.0
var pulled: bool = false

func pull_out_carrot() -> bool:
	# TODO return true if carrot is fully pulled
	pull_count += 1
	print("pulled carrot (" + str(pull_count) + " | " + str(max_pulls) + ")")

	if pull_count >= max_pulls:
		start_animation(ANIM_CARROT.PULLOUT)
		pulled = true
		return true
	else:
		if state != ANIM_CARROT.WIGGLE:
			start_animation(ANIM_CARROT.WIGGLE)
		else:
			time = 0.0
		return false

func _process(delta: float) -> void:
	time += delta
	if time >= animation_time_end:
		_stop_animation()
		time = 0

func _ready() -> void:
	base_rotation = rotation
	base_position = position

func start_animation(anim: ANIM_CARROT):
	_stop_animation()
	match anim:
		ANIM_CARROT.IDLE:
			pass
		ANIM_CARROT.WIGGLE:
			if state != ANIM_CARROT.WIGGLE:
				print("starting new wiggle")
				animation_time_end = 0.7
				var angle_rad = deg_to_rad(wiggle_angle_deg)
				tween = create_tween()
				tween.set_loops()
				tween.tween_property(self, "rotation:y", base_rotation.y + angle_rad, wiggle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				tween.parallel().tween_property(self, "position:x", base_position.x + wiggle_offset, wiggle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(self, "rotation:y", base_rotation.y - angle_rad, wiggle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				tween.parallel().tween_property(self, "position:x", base_position.x - wiggle_offset, wiggle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				time = 0.0
		ANIM_CARROT.PULLOUT:
			animation_time_end = 5
			tween = create_tween()
			var start_pos = position
			var target_pos = start_pos + Vector3(0, 22, 0)  # Move 1.5 units up
			tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	state = anim

func _stop_animation():
	match state:
		ANIM_CARROT.WIGGLE:
			print("ending wiggle")
			rotation = base_rotation
			position = base_position
		ANIM_CARROT.PULLOUT:
			pass
	
	if tween and tween.is_running():
		tween.kill()
		tween = null
	
	state = ANIM_CARROT.IDLE
