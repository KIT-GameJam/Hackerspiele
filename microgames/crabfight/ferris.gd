extends CharacterBody2D

const GRAVITY := 8000.0
const MIN_DIST := 250.0

@onready var left_arm: Node2D = $LeftArm
@onready var right_arm: Node2D = $RightArm
@onready var left_leg: Node2D = $LeftLeg
@onready var right_leg: Node2D = $RightLeg
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var invincibility: AnimationPlayer = $Invincibility
@export var accel := 600.0
@export var speed := 420.0
@export var damp := 0.0001
@export var jump_power := 2000.0
@export var controlled_by_player := false
@export var max_lifes := 4
var competitor: CharacterBody2D = null
var stab_timer := 0.0
var jump_timer := 0.0
var lifes: int
var progress: ProgressBar = null

func enable_mark() -> void:
	$Marker.show()

func _ready() -> void:
	lifes = max_lifes
	left_leg.toggle_dir()

func _physics_process(delta: float) -> void:
	move_and_slide()
	var dir := 0.0
	var is_jump := false
	var is_stab := false
	if controlled_by_player:
		dir = Input.get_axis("left", "right")
		is_jump = Input.is_action_just_pressed("up")
		is_stab = Input.is_action_just_pressed("submit")
	elif competitor:
		var target_pos := competitor.position.x
		if target_pos < position.x:
			target_pos += MIN_DIST
		else:
			target_pos -= MIN_DIST
		var delta_dir := target_pos - position.x
		dir = 1.0 if delta_dir > 0.0 else -1.0
		if abs(delta_dir) < 20.0:
			if (competitor.position.x > position.x) != (scale.x > 0.0):
				dir = -1.0 if competitor.position.x > position.x else 1.0
			else:
				dir = 0.0
		stab_timer -= delta
		if stab_timer < 0.0:
			stab_timer = randf_range(0.05, 0.7)
			is_stab = true
		jump_timer -= delta
		if jump_timer < 0.0:
			jump_timer = randf_range(0.0, 2.0)
			is_jump = true
	for leg in [left_leg, right_leg]:
		leg.set_playing(dir != 0)
	var t_accel := accel
	if dir != 0.0 and ((velocity.x > 0.0) != (dir > 0.0)):
		t_accel *= 8.0
	if dir:
		velocity.x += dir * t_accel * delta
	else:
		velocity.x *= pow(damp, delta)
	velocity.x = clampf(velocity.x, -speed, speed)
	if is_jump and is_on_floor():
		velocity.y -= jump_power
	if is_stab and not anim.is_playing():
		anim.play("stab")
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if controlled_by_player:
		if dir > 0.0:
			scale.x = scale.y
		elif dir < 0.0:
			scale.x = -scale.y
	else:
		scale.x = -scale.y if position.x > competitor.position.x else scale.y

func got_hit(node: Node2D) -> void:
	if node != competitor:
		return
	if anim.is_playing() and competitor.anim.is_playing():
		knife_collide()
	else:
		if not competitor.invincibility.is_playing():
			competitor.lifes -= 1
			if competitor.lifes <= 0:
				get_parent().finished.emit(MicroGame.Result.Win if controlled_by_player else MicroGame.Result.Loss)
			competitor.invincibility.play("invincible")
			get_parent().update_lifes_of(competitor)

func knife_collide() -> void:
	get_parent().knife_collide()
