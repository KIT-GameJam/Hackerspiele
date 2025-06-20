extends AnimatableBody2D

@export var toast: RigidBody2D

const CHARGEUP_SPEED = 1.0
const ROTATE_TOASTER_SPEED = 2.5

var rot_changed = false
var toast_locked = false

var chargeup = 0.0 # Normalized from 0 to 1
var charging_up = false
var time_toasted = 0.0

func _ready() -> void:
	assert(toast)
	#reset_toast_to($ToastAnchor.global_transform)

func _physics_process(delta: float) -> void:
	rot_changed = false

	if Input.is_action_pressed("left"):
		rotation -= delta * ROTATE_TOASTER_SPEED
		rot_changed = true
	if Input.is_action_pressed("right"):
		rotation += delta * ROTATE_TOASTER_SPEED
		rot_changed = true
	#if rot_left_pressed:
		#rotation += delta * f10
	#if rot_right_pressed:
		#rotation -= delta * 10+.
	if charging_up:
		chargeup += delta * CHARGEUP_SPEED
		chargeup = clamp(chargeup, 0.0 , 1.0)
		time_toasted += delta
		if time_toasted > 0.75:
			$AnimationPlayer.play("toaster_blink")
		if time_toasted > 1.5:
			$AnimationPlayer.speed_scale = 4.0
	
	$SpringHandleAnchor/SpringHandle.position.y = chargeup * 360
	
	if toast_locked:
		reset_toast_to($ToastAnchor.global_transform)
	
	toast.set_toastedness(time_toasted)

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("left"):
		#rot_left_pressed = true
	#if event.is_action_pressed("right"):
		#rot_right_pressed = true
	
	#if event.is_action_released("left"):
		#rot_left_pressed = false
	#if event.is_action_released("right"):
		#rot_right_pressed = false
	
	if event.is_action_pressed("up"):
		pull_in_toast()
	
	if event.is_action_pressed("submit"):
		pull_in_toast()
		chargeup = 0
		time_toasted = 0
		charging_up = true

	if event.is_action_released("submit"):
		print("POP")
		charging_up = false
		pop_toast()
		chargeup = 0

func reset_toast_to(rst_transform: Transform2D):
	toast.freeze = false
	PhysicsServer2D.body_set_state(toast.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, rst_transform)
	PhysicsServer2D.body_set_state(toast.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	PhysicsServer2D.body_set_state(toast.get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, Vector2.ZERO)
	toast.position = rst_transform.origin
	toast.rotation = rst_transform.get_rotation()
	toast.freeze = true

func pull_in_toast():
	#toast.freeze = true
	#t1.tween_property(toast, "position", position,1.0).set_ease(Tween.EASE_IN_OUT)
	#t1.tween_property(toast, "rotation", rotation, 1.0).set_ease(Tween.EASE_IN_OUT)
	
	#await t1.finished

	reset_toast_to($ToastAnchor.global_transform)
	$AnimationPlayer.speed_scale = 1.0
	$AnimationPlayer.play("RESET")
	toast_locked = true

func pop_toast():
	toast.freeze = false
	#var t1 = create_tween()
	#toast.freeze = false
	toast.apply_impulse(Vector2.UP.rotated(rotation) * 2000.0 * chargeup)
	$ToastInsideCheckArea.set_collision_layer_value(1, true)
	$AnimationPlayer.play("RESET")
	toast_locked = false
