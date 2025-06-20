extends AnimatableBody2D

@export var toast: RigidBody2D

const CHARGEUP_SPEED = 2.0
const ROTATE_TOASTER_SPEED = 3.0

var rot_changed = false
var toast_locked = false

var chargeup = 0.0 # Normalized from 0 to 1
var charging_up = false

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
	
	$SpringHandleAnchor/SpringHandle.position.y = chargeup * 360
	
	if toast_locked:
		reset_toast_to($ToastAnchor.global_transform)

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
	var t1 = create_tween()
	#toast.freeze = true
	#t1.tween_property(toast, "position", position,1.0).set_ease(Tween.EASE_IN_OUT)
	#t1.tween_property(toast, "rotation", rotation, 1.0).set_ease(Tween.EASE_IN_OUT)
	
	#await t1.finished

	reset_toast_to($ToastAnchor.global_transform)
	toast_locked = true

func pop_toast():
	toast.freeze = false
	var t1 = create_tween()
	#toast.freeze = false
	toast.apply_impulse(Vector2.UP.rotated(rotation) * 2000.0 * chargeup)
	$ToastInsideCheckArea.set_collision_layer_value(1, true)
	toast_locked = false

func _on_toast_inside_check_area_body_exited(body: Node2D) -> void:
	pass

func _on_toast_inside_check_area_body_entered(body: Node2D) -> void:
	pass
