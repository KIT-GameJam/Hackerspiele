@tool
extends Camera2D

## How quickly the shake intensity diminishes.
@export var decay_rate: float = 5.0
## The maximum distance the camera can be offset from its original position.
@export var max_offset: Vector2 = Vector2(20, 20)
## The maximum angle the camera can be rotated.
@export var max_roll: float = 0.05
## The frequency of the noise used for shaking.
@export var noise_frequency: float = 2.0
## The speed at which the noise pattern is traversed.
@export var noise_speed: float = 10.0

var trauma: float = 0.0
var noise = FastNoiseLite.new()
var noise_y: float = 0

func _ready():
	# Initialize the noise generator
	noise.seed = randi()
	noise.frequency = noise_frequency

func _process(delta):
	if trauma > 0:
		# Decrease trauma over time
		trauma = lerpf(trauma, 0, decay_rate * delta)

		# Apply the shake effect
		_apply_shake()
	else:
		# Reset the camera's offset and rotation when not shaking
		offset = Vector2.ZERO
		rotation = 0

## Applies a one-time shake that slowly fades.
## @param strength: The intensity of the shake, from 0.0 to 1.0.
func tremor(strength: float):
	trauma = min(trauma + strength, 1.0)

func _apply_shake():
	var amount = pow(trauma, 2)

	# Update the noise position to create movement
	noise_y += noise_speed

	# Generate noise for offset and rotation
	var noise_x_val = noise.get_noise_1d(noise_y)
	var noise_y_val = noise.get_noise_1d(noise_y + 100)
	var noise_rot_val = noise.get_noise_1d(noise_y + 200)

	# Apply the offset and rotation based on the noise and trauma
	offset.x = max_offset.x * amount * noise_x_val
	offset.y = max_offset.y * amount * noise_y_val
	rotation = max_roll * amount * noise_rot_val
