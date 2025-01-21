extends KinematicBody2D

enum {
	IDLE,
	WANDER,
	ATTACK,
	DEAD
}

var state = IDLE
var knockback_distan = Vector2.ZERO
var knockback_direc = 1
var knockback_power = 500
var gravity = 34
var velocity = Vector2.ZERO
var fog_spawned = 0
var dissolveRate = -1.0
var dark_colored = false

var shoot_times = 1
var bullet_speed = 1000

onready var animatedSprite = $Sprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var hurtboxShape = $Hurtbox/CollisionShape2D
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var bulletSpawnPoint = $BulletSpawnPoint

export var acceleration = 800
export var max_speed = 1000
export var friction = 200
export var WANDER_TARGET_RANGE = 4
export var retreat_speed = -150
export var is_constant = false

const FLOOR = Vector2(0, -1)
const EnemyDeathEffect = preload("res://Effect/EnemyDeathEffect.tscn")
const Bullet = preload("res://Enemy/TestingMonsterBullet.tscn")

func _ready():
	state = pick_random_state([IDLE, WANDER])
	animatedSprite.material.set_shader_param("dissolveRate", -1)

func _physics_process(delta):
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			shoot_times = 1
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()

		WANDER:
			seek_player()
			shoot_times = 1
			if wanderController.get_time_left() == 0:
				update_wander()
			acceleration_towards_point(wanderController.target_position, delta, 1)
			
			if global_position.distance_to(wanderController.target_position) <= WANDER:
				update_wander()
			
		ATTACK:
			var playerDetect = playerDetectionZone.player
			if playerDetect != null:
				acceleration_towards_point(playerDetect.global_position, delta, 2)
				shoot_bullet()
				shoot_times -= 1
				
			else:
				state = IDLE

		DEAD:
			velocity.x = 0
			hurtboxShape.disabled = true
			velocity.y += gravity 							#enable gravity
			animatedSprite.flip_h = velocity.x > 0 

			if dark_colored == true:
				modulate.a -= 2 * delta
				call_deferred("Spawn_fog")
				$CollisionShape2D.disabled = true
				if modulate.a <= 0:
					queue_free()
			else:
				dissolveRate += delta
				if dissolveRate >= 0.5:
					call_deferred("Spawn_fog")
					if dissolveRate >= 1:
						queue_free()
	
	velocity = move_and_slide(velocity, FLOOR)		#enable motions
	if dark_colored == true:			#enable gravity, flying
		velocity.y += gravity
	animatedSprite.material.set_shader_param("dissolveRate", dissolveRate)
	
	knockback_distan = knockback_distan.move_toward(Vector2.ZERO, 200 * delta)
	knockback_distan = move_and_slide(knockback_distan)
	knockback_direc = PlayerStats.playerFrontDir
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 500
	
	if global_position.x < PlayerStats.playerPosition.x:
		bulletSpawnPoint.position.x = abs(bulletSpawnPoint.position.x)
	else:
		bulletSpawnPoint.position.x = -abs(bulletSpawnPoint.position.x)
		
func seek_player():
	if playerDetectionZone.can_see_player():
		state = ATTACK

func acceleration_towards_point(point, delta, motion_state):
	var direction = global_position.direction_to(point)

	if motion_state == 1:		#normal
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
		animatedSprite.flip_h = velocity.x < 0

	elif motion_state == 2:		#attack
		velocity = velocity.move_toward(direction * retreat_speed, acceleration * delta)
		animatedSprite.flip_h = global_position.x > PlayerStats.playerPosition.x

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func shoot_bullet():
	if is_constant == false:
		state = ATTACK
	else:
		state = IDLE
	
	if shoot_times == 1:
		var bullet = Bullet.instance()
		
		get_parent().add_child(bullet)
		bullet.global_position = bulletSpawnPoint.global_position
		bullet.velocity = bullet.position.direction_to(PlayerStats.playerPosition) * bullet_speed

func _on_Hurtbox_area_entered(area):
	var total_damage = 0
	
	hurtbox.create_hit_effect()
	velocity = Vector2.ZERO
	
	if knockback_direc == 1:
		knockback_distan = Vector2.RIGHT * knockback_power
	elif knockback_direc == 2:
		knockback_distan = Vector2.LEFT * knockback_power
		

	if area.is_skill1 == true:
		total_damage = PlayerStats.skill1_base_damage + PlayerStats.magical_damage * 0.15
		stats.health -= total_damage * stats.magical_resistance
		
		hurtbox.create_floating_text(total_damage, 1)		#magical data
		area.get_parent().queue_free()
	
	elif area.is_sp_bullet == true:
		total_damage = PlayerStats.physical_damage * PlayerStats.sp_bullet_damage_rate * stats.physical_resistance
		stats.health -= total_damage
		
		hurtbox.create_floating_text(total_damage, 2)		#physical data
	
	elif area.is_skill1_gathered == true:
		total_damage = PlayerStats.skill1_base_damage + PlayerStats.magical_damage * 0.15
		stats.health -= total_damage * stats.magical_resistance
		
		hurtbox.create_floating_text(total_damage, 1)		#magical data
		
		if dark_colored == false:
			var true_damage = 0
			true_damage = total_damage * 0.001 + stats.max_health * 0.03
			dark_colored = true
			dissolveRate = 2.224
			acceleration *= 0.5
			max_speed = acceleration + 1
			
			stats.health -= true_damage
			hurtbox.create_floating_text(true_damage, 3)
			
	else:
		total_damage = PlayerStats.magical_damage * stats.magical_resistance + PlayerStats.physical_damage * stats.physical_resistance
		stats.health -= total_damage
		
		hurtbox.create_floating_text(PlayerStats.magical_damage * stats.magical_resistance, 1)		#magical data
		hurtbox.create_floating_text(PlayerStats.physical_damage * stats.physical_resistance, 2)		#physical data
		#hurtbox.start_invincibility(0.5)	#invincible time
	
	if dark_colored == true:
		var true_damage = 0
		true_damage = total_damage * 0.001 + stats.max_health * 0.1
		stats.health -= true_damage
		hurtbox.create_floating_text(true_damage, 3)
	else:
		if dissolveRate < -0.1:
			dissolveRate = -1 + 0.6 * 2 * (1 - stats.health/stats.max_health)

	if PlayerStats.The_energy >= PlayerStats.Tdamage_trigger && dark_colored == false:			#trigger true damage
		var true_damage = 0
		true_damage = total_damage * 0.001 + stats.max_health * 0.03
		dark_colored = true
		dissolveRate = 2.224
		acceleration *= 0.3						#fly
		max_speed = acceleration + 1
		
		stats.health -= true_damage
		hurtbox.create_floating_text(true_damage, 3)
		
	Player_health_gaining()

func _on_Stats_no_health():
	state = DEAD
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func Spawn_fog():
	if fog_spawned < 1:
		var magiFog = preload("res://Effect/MagiFog.tscn").instance()
		get_parent().get_parent().get_node("Magifog").add_child(magiFog)
		magiFog.global_position = global_position
		fog_spawned += 1

func Player_health_gaining():				#globally identical required
	if PlayerStats.The_energy >= 2:
		PlayerStats.health += 0.5
