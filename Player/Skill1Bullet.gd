extends KinematicBody2D

onready var enemyDetectionZone = $EnemyDetectionZone
onready var particles2D = $Effect/Particles2D
onready var effect = $Effect
onready var hitboxShape = $Hitbox/CollisionShape2D
onready var tween = $Tween
onready var enemyDetectionShape = $EnemyDetectionZone/CollisionShape2D

var velocity = Vector2.ZERO
var max_speed = 1600
var acceleration = 1400
var despawn = false
var can_hit = false
var state_forward = false
var state_around = false
var forward_dir = 1
var forward_speed = 1800		# MUST equals to effect speed
var forward_max_speed = 1500
var init_dir = Vector2(rand_range(-200, 200), rand_range(-100, 100)) + PlayerStats.playerPosition
var can_hit_changed = false
var start_detecting = true

func _ready():
	change_effect_state(true, -300, true)
	tween.interpolate_property(effect, "modulate", Color("ffffff"), Color("00ffffff"), 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	enemyDetectionShape.shape.radius = 0

func _physics_process(delta):
	if start_detecting == true:
		if enemyDetectionShape.shape.radius < 1500:
			enemyDetectionShape.shape.radius += 200 * delta
		else:
			enemyDetectionShape.shape.radius = 0
	
	velocity = move_and_slide(velocity)
	effect.modulate.b = 1 - PlayerStats.The_energy * 0.4				#change of color after absorbing
	effect.modulate.g = 1 + PlayerStats.The_energy * 0.3
	effect.modulate.a = 1 + PlayerStats.The_energy * 0.05
	
	if despawn == true:
		tween.start()
	
	if Input.is_action_just_pressed("skill1_forward") && state_forward == false:
		velocity = Vector2.ZERO
		global_position.x = PlayerStats.playerPosition.x + rand_range(-200, 200)
		global_position.y = PlayerStats.playerPosition.y + rand_range(-80, 80)

		state_forward = true
		forward_dir = PlayerStats.playerFrontDir
		
	if state_forward == true:
		if abs(velocity.x) < forward_max_speed:
			change_effect_state(false, 0, true)
			if forward_dir == 1:
				velocity.x += forward_speed * delta
			else:
				velocity.x -= forward_speed * delta
		else:
			change_effect_state(false, 0, false)
			if forward_dir == 1:
				velocity.x = forward_max_speed
			else:
				velocity.x = -forward_max_speed

	elif state_around == true:
		var direction = global_position.direction_to(PlayerStats.weaponPosition)
		change_effect_state(false, 0, false)
		velocity = velocity.move_toward(direction * max_speed, acceleration * 2  * delta)

	else:
		if Input.is_action_just_pressed("skill1_around"):
			velocity = Vector2.ZERO
			state_around = true

		if can_hit == true:
			if can_hit_changed == false:
				velocity = Vector2.ZERO
				can_hit_changed = true

			var direction = Vector2.ZERO
			if enemyDetectionZone.player != null:		#player means enemy at this point
				direction = global_position.direction_to(enemyDetectionZone.player.position)
				velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
				start_detecting = false
			else:
				start_detecting = true

			if velocity == Vector2.ZERO:
				change_effect_state(false, -300, false)
			else:
				change_effect_state(false, 0, false)
				
		else:
			var direction = global_position.direction_to(init_dir)
			velocity = velocity.move_toward(direction * rand_range(0, 2000), rand_range(0, 2500) * delta)
			change_effect_state(false, 0, true)
			
func change_effect_state(lc, gy, hd):
	particles2D.local_coords = lc
	particles2D.process_material.set_gravity(Vector3(0, gy, 0))
	hitboxShape.disabled = hd

func _on_Despawn_timeout():
	despawn = true

func _on_Tween_tween_all_completed():
	queue_free()

func _on_Start_timeout():
	can_hit = true

func _on_VisibilityNotifier2D_screen_exited():
	if state_forward == true:
		tween.start()
