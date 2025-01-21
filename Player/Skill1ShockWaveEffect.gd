extends KinematicBody2D

var velocity = Vector2.ZERO
var speed = 1800		# equals to bullet speed
var max_speed = 1500
var dir = 0
var the_delta = 0

onready var particleEffect = $Particles2D

func _ready():
	particleEffect.emitting = false
	dir = PlayerStats.playerFrontDir

func _physics_process(delta):
	the_delta = delta
	velocity = move_and_slide(velocity)
	
	if abs(velocity.x) < max_speed:
		particleEffect.emitting = false
		$Hitbox/CollisionShape2D.disabled = true
		if dir == 1:
			velocity.x += speed * delta
			particleEffect.rotation_degrees = 180
		else:
			velocity.x -= speed * delta
			particleEffect.rotation_degrees = 0

	else:
		particleEffect.emitting = true
		$Hitbox/CollisionShape2D.disabled = false
		if dir == 1:
			velocity.x = max_speed
			particleEffect.rotation_degrees = 180
		else:
			velocity.x = -max_speed
			particleEffect.rotation_degrees = 0
	
	particleEffect.modulate.b = 1 - PlayerStats.The_energy * 0.4				#change of color after absorbing
	particleEffect.modulate.g = 1 + PlayerStats.The_energy * 0.3
	particleEffect.modulate.a = 1 + PlayerStats.The_energy * 0.1
	
func _on_VisibilityNotifier2D_screen_exited():
	$despawn.start()

func _on_despawn_timeout():
	queue_free()
