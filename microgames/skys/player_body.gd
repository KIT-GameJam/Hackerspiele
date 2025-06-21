class_name PlayerBody
extends CharacterBody2D

signal hit_registered

# Constants:
const base_speed = 10.;
# idea: store up jump "force/energy" by pressing down and apply accel when button released
#var jump_acceleration = 20; # m/s²
const gravity = 9.8*3; # m/s^2
const floor_level = 0; # y coordinate of floor
const physics_scale = 45
const jump_charge_force: float = 500.*3.8 # in "Newton" :D
const jump_max_charge: float = 500 * 1.5# in N*s, 1s to charge to max
const mass: float = 1. # player mass in kg
var jump_charge: float = 0. # impulse in N*s
var jump_now: bool = false # trigger jump

@onready var player_mesh := $PlayerMeshTransform/PlayerMesh
@onready var charge_gradient : Gradient = load("res://microgames/skys/charge_gradient.tres")

func register_hit_by_obstacle(obstacle: Node2D):
	print_debug("collision in player")
	hit_registered.emit()
	
func _process(delta: float) -> void:
	# Built in race condition: see if you can release and repress the jump button befor the next 
	# physics_process() runs, to reset jump charge.
	if Input.is_action_just_pressed("submit"):
		print("just press")
		jump_charge = 0.
	if Input.is_action_pressed("submit"):
		print("press")
		jump_charge += jump_charge_force * delta
		jump_charge = minf(jump_max_charge, jump_charge)
	if Input.is_action_just_released("submit"):
		print("release")
		jump_now = true

	# Visualize charge state:
	var charge_ratio = jump_charge/jump_max_charge;
	const charged_scale := Vector2(2., 0.5)
	var current_scale = lerp(Vector2(1., 1.), charged_scale, charge_ratio)
	# Use dummy transform to apply rescale "after" mesh origin is moved to the
	# model's "feet"
	$PlayerMeshTransform.scale = current_scale
	set_player_color(charge_gradient.sample(charge_ratio))
	#player_mesh.material.set("shader_parameter/player_charge", charge_ratio);
	#player_mesh.material.set("shader_parameter/player_charge", 1.);
	
	
func _physics_process(delta: float) -> void:
	# stuff:
	var acceleration = Vector2(0, 0)
	var is_airborne : bool = position.y < 0
	
	#var updown_dir = Input.get_axis("down", "up")
	#acceleration += up_direction * updown_dir * jump_acceleration
	#acceleration += up_direction
	if is_airborne:
		# in air
		acceleration += up_direction * -gravity
	else:
		# On or below ground
		# cancel upwards motion, needlessly complex...
		velocity -= up_direction * velocity.dot(up_direction)
		#velocity.y = 0
		pass
	
	# apply jump impulse:
	if jump_now:
		print("jump now")
		if is_on_floor():
			velocity += up_direction * jump_charge / mass
		jump_now = false
		jump_charge = 0.
		
	
	velocity.x = physics_scale * base_speed
	velocity += physics_scale * acceleration * delta # integrate accelarations
	#velocity.x = base_speed * lr_dir
	
	move_and_slide()
	#velocity.y = 2
	
func set_player_color(color: Color):
	(player_mesh.texture as GradientTexture1D).gradient.set_color(0, color)
