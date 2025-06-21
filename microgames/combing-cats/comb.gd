extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var claw_pos:Vector2


func _physics_process(delta: float) -> void:


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left","right","up","down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		

	move_and_slide()


func _on_main_scratch() -> void:
	position = claw_pos
