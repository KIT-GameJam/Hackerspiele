extends RigidBody2D

var toastedness

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
