class_name MartianMikePlayer extends CharacterBody2D

const audio_player_scene = preload("res://microgames/martian_mike/entities/player/audio_player.tscn")

@onready var animated_sprite = $AnimatedSprite2D
@onready var cam := $Camera2D
@onready var audio_player := $AudioPlayer

enum MovementPhase { STANDING = 0, ACCELERATING = 1, DECELERATING = 2, TURNING = 3 }
const JUMP_VELOCITY := 350.0
const ADDITIONAL_FALLING_GRAVITY := 100.0
const COYOTE_TIME := 5
const JUMP_BUFFER_FRAMES := 5
const ACCELERATION_SPEED := 700.0
const DECELERATION_SPEED := 550.0
const TURNING_SPEED := 1500.0
const MAX_SPEED := 170.0
const EPSILON := 0.001
const LOOK_AHEAD_MAX := 140.0
const LOOK_AHEAD_SPEED := 200.0
var movement_phase := MovementPhase.STANDING
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction := 0.0
var walk_vel := 0.0
var lookahead := 0.0
var frames_since_ground := 0
var is_turned_right := true
var jump_buffer := 0
var active = true

func _physics_process(delta):
	handle_gravity(delta)
	handle_jump(delta)
	handle_movement(delta)
	update_animations(direction)
	move_and_slide()

func handle_gravity(delta):
	if not is_on_floor():
		frames_since_ground += 1
		velocity.y += gravity * delta
		if velocity.y >= 0.0:
			velocity.y += ADDITIONAL_FALLING_GRAVITY * delta
	else:
		frames_since_ground = 0

func handle_jump(_delta):
	if Input.is_action_just_pressed("submit"):
		jump_buffer = JUMP_BUFFER_FRAMES
	if jump_buffer > 0 and ((frames_since_ground <= COYOTE_TIME) or is_on_floor()):
		jump(JUMP_VELOCITY)
		frames_since_ground = COYOTE_TIME
		jump_buffer = 0
	if jump_buffer > 0:
		jump_buffer -= 1

func handle_movement(delta):
	direction = Input.get_axis("left", "right")
	if direction:
		lookahead = direction * LOOK_AHEAD_MAX
	cam.offset.x = move_toward(cam.offset.x, lookahead, LOOK_AHEAD_SPEED * delta)

	match movement_phase:
		MovementPhase.STANDING:
			walk_vel = 0
			if direction != 0:
				movement_phase = MovementPhase.ACCELERATING
		MovementPhase.ACCELERATING:
			if direction == 0:
				movement_phase = MovementPhase.DECELERATING
			elif (direction > 0) == is_turned_right:
				walk_vel = move_toward(walk_vel, MAX_SPEED * sign(direction),
					delta * abs(direction) * ACCELERATION_SPEED)
			else:
				movement_phase = MovementPhase.TURNING
		MovementPhase.DECELERATING:
			if direction != 0:
				movement_phase = MovementPhase.ACCELERATING if sign(direction) == sign(walk_vel) else MovementPhase.TURNING
			else:
				walk_vel = move_toward(walk_vel, 0, delta * DECELERATION_SPEED)
				if abs(walk_vel) <= EPSILON:
					movement_phase = MovementPhase.STANDING
		MovementPhase.TURNING:
			if direction == 0:
				movement_phase = MovementPhase.DECELERATING
			else:
				walk_vel = move_toward(walk_vel, 0, delta * TURNING_SPEED)
				if abs(walk_vel) <= EPSILON:
					movement_phase =  MovementPhase.ACCELERATING
	is_turned_right = direction > 0
	velocity.x = walk_vel

func update_animations(_direction):
	if is_on_floor():
		if _direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	if _direction != 0:
		animated_sprite.flip_h = (_direction == -1)

func jump(force):
	velocity.y = -force
	audio_player.play_sfx("jump")

func on_player_hurt():
	audio_player.play_sfx("hurt")
