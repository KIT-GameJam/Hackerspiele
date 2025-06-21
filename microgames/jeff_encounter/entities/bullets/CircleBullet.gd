extends AlienAttackBullet

const ACCELERATION := 24.0
const ANGULAR_VELOCITY := 1.8

func _physics_process(delta):
	direction = direction.rotated(delta * ANGULAR_VELOCITY)
	speed += delta * ACCELERATION
	super._physics_process(delta)
