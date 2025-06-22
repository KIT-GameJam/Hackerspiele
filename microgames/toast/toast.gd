extends RigidBody2D

var toastedness

# --- Your existing functions are great, no changes needed here ---
func _ready() -> void:
	set_toastedness(0.0)

func set_toastedness(p_toastedness: float):
	self.toastedness = p_toastedness

	var mat : ShaderMaterial = $ToastSprite.material
	mat.set_shader_parameter("toastedness", toastedness)
	var smoke_particles : GPUParticles2D = $Smoke
	var process_mat : ParticleProcessMaterial = smoke_particles.process_material
	process_mat.color = Color.TRANSPARENT.lerp(Color.WHITE, toastedness)
	if toastedness > 1.0:
		process_mat.color = Color.WHITE.lerp(Color.DARK_GRAY.darkened(0.2), clamp(toastedness - 1.0, 0.0, 1.0))

	if toastedness > 0.1:
		smoke_particles.emitting = true
	else:
		smoke_particles.emitting = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Loop through all collisions that happened this frame
	for i in range(state.get_contact_count()):
		# Get the body we collided with
		var collider = state.get_contact_collider_object(i)

		# Check if the body is a bumper
		if collider is StaticBody2D and collider.is_in_group("bumpers"):
			print("bump")

			# Get the normal vector of the collision point
			var normal = state.get_contact_local_normal(i)

			# Calculate the reflection using the built-in bounce function
			# We can also add a "bounciness" factor here. 1.0 is a perfect reflection.
			var bounciness = 1.0
			state.linear_velocity = state.linear_velocity.bounce(normal) * bounciness

			# Optional: Apply a fixed impulse boost on each bounce
			state.apply_central_impulse(normal * 600.0)

			# Call the bumper's function
			collider.bumper_bumped()
