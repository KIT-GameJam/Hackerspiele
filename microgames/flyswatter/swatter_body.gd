extends RigidBody2D

signal fly_swatted

const SPEED = 10.0
var _has_fly: bool

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("submit"):
		_swat()

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left","right","up","down")
	if direction:
		apply_impulse(direction * SPEED)

func _swat() -> void:
	$AnimationPlayer.play("swat")
	if _has_fly:
		fly_swatted.emit()

func _on_flyswatter_body_entered(body: Node2D) -> void:
	_has_fly = true

func _on_flyswatter_body_exited(body: Node2D) -> void:
	_has_fly = false
