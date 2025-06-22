extends CharacterBody2D

const Bullet = preload("res://microgames/jeff_encounter/entities/bullets/PointBullet.tscn")

const SPEED: float = 90.0
const DASH_FACTOR := 4.0

var is_invincible := false
var can_dash := true
var dashing := false
var knockback := Vector2(0, 0)

signal was_hit

@onready var jeff_tex: Texture2D = load("res://microgames/jeff_encounter/assets/textures/Jeff.png")
@onready var keff_tex: Texture2D = load("res://microgames/jeff_encounter/assets/textures/Keff.png")

func _physics_process(_delta):
	var direction := Input.get_vector("left", "right", "up", "down")
	var has_input := direction.x != 0 or direction.y != 0
	if Input.is_action_just_pressed("submit") and can_dash:
		can_dash = false
		$DashCooldownTimer.start()
		$DashTimer.start()
		dashing = true
		$HitBox/CollisionShape2D.disabled = true
		$Character.texture = keff_tex
		$GPUParticles2D.restart()
		$DustFadeAnimationPlayer.play('fade')
		$DashSoundPlayer.play()
	if dashing:
		if not has_input:
			direction = Vector2(1 if $Character.scale.x < 0 else -1, 0)
		direction *= DASH_FACTOR
	if direction.x > 0:
		$Character.scale = Vector2i(-1, 1)
	elif direction.x < 0:
		$Character.scale = Vector2i(1, 1)
	direction += knockback

	velocity = direction * SPEED
	var collided := move_and_slide()
	$WalkAnimationPlayer.play('walk' if has_input and not collided else 'idle')

	var vp := get_viewport()
	var _off := 0.5 * vp.get_visible_rect().size / vp.get_camera_2d().zoom

func hit_player(_direction: Vector2):
	was_hit.emit()
	$HitSoundPlayer.play()
	$HitAnimationPlayer.play("hit")

func _on_invincibility_timer_timeout() -> void:
	$HitAnimationPlayer.stop()
	is_invincible = false

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
	$Character.texture = jeff_tex

func _on_dash_timer_timeout() -> void:
	dashing = false
	$HitBox/CollisionShape2D.disabled = false
