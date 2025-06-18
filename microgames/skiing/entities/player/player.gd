class_name Player
extends CharacterBody3D

const MOVEMENT_SPEED              := 8.0
const MOMENTUM_SPEED              := 40.0
const FLIP_SPEED                  := 6.0
const JUMP_VELOCITY               := 6.5
const FLOW_PENALTY_FELLED_ON_HEAD := 0.5
const FLOW_BOOST_PER_FLIP         := 3.0
const FLOW_BOOST_COOLDOWN         := 4.0
const MAX_FLOW_BOOST              := 4.0
const ROTATE_RESET_COOLDOWN       := 0.2
@export var INITIAL_FLOW_FACTOR := 0.6

var flow_factor                 := INITIAL_FLOW_FACTOR
var flow_tween: Tween
var rotate_tween: Tween
var flips: int                  =  0
var flip_countable: bool        =  false
var was_in_air: bool            =  false
var momentum: float             =  0.0
var height_last_frame: float    =  0.0

@onready var camera: Camera3D = $Camera3D


func _ready():
	flow_tween = get_tree().create_tween()
	rotate_tween = get_tree().create_tween()
	flow_tween.tween_property(self, "flow_factor", 1.0, FLOW_BOOST_COOLDOWN)
	rotate_tween.tween_property(self, "rotation", Vector3(0, 0, 0), .5)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		var tilt_dir := Input.get_axis("up", "down")
		rotate_x(tilt_dir * delta * FLIP_SPEED)
		velocity += get_gravity() * delta
		was_in_air = true;
	elif was_in_air:
		_on_jump_ended()
	else:
		momentum = (height_last_frame - global_position.y) * MOMENTUM_SPEED
	
	_count_flips();

	# Handle jump.
	if Input.is_action_just_pressed("submit") and is_on_floor():
		_on_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_axis("left", "right")
	var direction := (transform.basis * Vector3(input_dir, 0, 0)).normalized()
	if direction:
		velocity.x = direction.x * MOVEMENT_SPEED * 2 / maxf((flow_factor / 4), 1.0)
		camera.rotation.z = lerp_angle(camera.rotation.z, direction.x * -0.2, 0.1)
		camera.rotation.y = lerp_angle(camera.rotation.y, direction.x * -0.2, 0.1)
	else:
		camera.rotation.z = move_toward(camera.rotation.z, 0, 0.2)
		camera.rotation.y = move_toward(camera.rotation.y, 0, 0.2)
		velocity.x = move_toward(velocity.x, 0, MOVEMENT_SPEED)

	velocity.z = MOVEMENT_SPEED * flow_factor * -1 - momentum

	height_last_frame = global_position.y
	move_and_slide()


func change_flow_factor(new_flow_factor: float):
	_tween_flow_factor(new_flow_factor)


func _on_jump_ended():
	if _is_upside_down():
		change_flow_factor(FLOW_PENALTY_FELLED_ON_HEAD)
	elif flips > 0:
		change_flow_factor(flips * FLOW_BOOST_PER_FLIP * flow_factor)
	flips = 0
	_tween_rotate_x()
	was_in_air = false

func _on_jump():
	velocity.y = JUMP_VELOCITY
	was_in_air = true


func _count_flips() -> void:
	if flip_countable and is_equal_approx(abs(rotation.x), 3.0):
		flips += 1
		flip_countable = false
	elif not _is_upside_down():
		flip_countable = true


func _is_upside_down() -> bool:
	return rotation.x > 0.5 or rotation.x < -0.5


func _tween_flow_factor(new_flow_factor: float):
	flow_tween = _tween_reset(flow_tween)
	flow_factor = minf(flow_factor * new_flow_factor, MAX_FLOW_BOOST)
	flow_tween.tween_property(self, "flow_factor", 1.0, FLOW_BOOST_COOLDOWN)


func _tween_rotate_x(new_rotation: float = .0):
	rotate_tween = _tween_reset(rotate_tween)
	rotate_tween.tween_property(self, "rotation", Vector3(new_rotation, 0, 0), ROTATE_RESET_COOLDOWN)


func _tween_reset(tween: Tween) -> Tween:
	tween.kill()
	return get_tree().create_tween()
	
