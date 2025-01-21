extends KinematicBody2D

enum {
	MOVE,
	ATTACK,
	DODGE,
	DEAD,
	StandStill
}

#ability related variables
var speed = 750
var jump_power = -1700
var dodge_power =2000
var gravity = 4600

var velocity = Vector2.ZERO
var on_ground = true
var state = MOVE
var front_dir = 1   #facing_direc, 1 = right, 2 = left
var attack_times = 0
var jump_times = 1
var skill_times = 1

onready var animatedSprite = $AnimatedSprite
onready var attaTimer = $AttaTimer
onready var weaponEffect = $WeaponEffect
onready var weaponEffectParticle = $WeaponEffect/Particles2D
onready var weaponPos = $WeaponPos
onready var collisionShape = $CollisionShape2D
onready var playerHurtbox = $Hurtbox/CollisionShape2D
onready var playerHurtboxDetect = $Hurtbox
onready var playerHitbox = $HitboxPivot/PlayerHitbox/CollisionShape2D
onready var playerHitboxDetect = $HitboxPivot/PlayerHitbox

#soundeffects
onready var attackSound = $SoundEffect/Attack

const FRICTION = 4000
const FLOOR = Vector2(0, -1)
const PlayerHurtEffect = preload("res://Effect/PlayerHurtEffect.tscn")
const Bullet = preload("res://Enemy/TestingMonsterBullet.tscn")

func _ready():
	randomize()
# warning-ignore:return_value_discarded
	Pause.full_recover()
	
func _physics_process(delta):							#main function
	match state:
		MOVE:
			PlayerMotion(delta)

		ATTACK:
			PlayerAttack(delta)

		DODGE:
			PlayerDodge(delta)

		#SKILL2:
		#	pass
		
		DEAD:
			queue_free()
		
		StandStill:
			collisionShape.disabled = false
			animatedSprite.play("Idle")
			playerHurtbox.disabled = true
			playerHitbox.disabled = true
			velocity.y += gravity * delta
			velocity.x = 0
			weaponEffect.visible = false
			velocity = move_and_slide(velocity, FLOOR)

	weaponEffect.global_position = weaponPos.global_position					#weapon effect motion
	
func PlayerMotion(delta):
	velocity = move_and_slide(velocity, FLOOR)		#enable motions
	velocity.y += gravity * delta 					#enable gravity
	if position.y > 4000:							#dealth for fall
		Pause.restart()
	
	if $Stats.health <= 0:
		state = DEAD
	
	if front_dir == 1:
		animatedSprite.flip_h = false
		playerHitbox.position.x = -abs(playerHitbox.position.x)
		collisionShape.position.x = -abs(collisionShape.position.x)
		playerHurtbox.position.x = -abs(collisionShape.position.x)
	elif front_dir == 2:
		animatedSprite.flip_h = true
		playerHitbox.position.x = abs(playerHitbox.position.x)
		collisionShape.position.x = abs(collisionShape.position.x)
		playerHurtbox.position.x = abs(collisionShape.position.x)
	
	if Input.is_action_just_pressed("player2_skill") && skill_times >= 1:
		skill_times = 0
		var bullet = Bullet.instance()
		get_parent().add_child(bullet)
		bullet.global_position = global_position
		bullet.velocity = bullet.position.direction_to(PlayerStats.playerPosition) * 2000
		
	#Hmotion
	if Input.is_action_pressed("player2_right"):
		velocity.x = speed
		front_dir = 1

	elif Input.is_action_pressed("player2_left"):
		velocity.x = -speed
		front_dir = 2

	else:
		if velocity.x > 0 && on_ground == true:
			animatedSprite.play("Brake")
			match animatedSprite.frame:
					0:
						weaponPos.position = Vector2(-68.133, 37.581)

					1:
						weaponPos.position = Vector2(-108.738, 84.223)

					2:
						weaponPos.position = Vector2(-108.738, 84.223)

					3:
						weaponPos.position = Vector2(-113.439, 78.167)

					4:
						weaponPos.position = Vector2(-136.564, 79.111)


			velocity.x -= FRICTION * delta			#friction applied
			if velocity.x < 0:
				velocity.x = 0

		elif velocity.x < 0 && on_ground == true:
			animatedSprite.play("Brake")
			match animatedSprite.frame:
					0:
						weaponPos.position = Vector2(68.133, 37.581)

					1:
						weaponPos.position = Vector2(108.738, 84.223)

					2:
						weaponPos.position = Vector2(108.738, 84.223)

					3:
						weaponPos.position = Vector2(113.439, 78.167)

					4:
						weaponPos.position = Vector2(136.564, 79.111)

			velocity.x += FRICTION * delta
			if velocity.x > 0:
				velocity.x = 0

	if Input.is_action_just_pressed("player2_dash"):				#dodge pressed
		state = DODGE
			#$Dodge_CD.start()

#Vmotion
	if Input.is_action_just_pressed("player2_jump"):
		if jump_times > 0:
			jump_times -= 1
			attack_times = 0
			if on_ground == true:
				velocity.y = jump_power
			else:
				velocity.y = jump_power + 200

#if is on floor & Motion animation
	if is_on_floor():
		on_ground = true
		jump_times = 1

		if velocity.x == 0:
			animatedSprite.play("Idle")

		if front_dir == 1:
			weaponPos.position = Vector2(-96.33, 77.76)

			if velocity.x > speed * 0.9:
				animatedSprite.play("Run")

				match animatedSprite.frame:
					0:
						weaponPos.position = Vector2(32, 0)

					1:
						weaponPos.position = Vector2(8, -56)

					2:
						weaponPos.position = Vector2(16, -64)

					3:
						weaponPos.position = Vector2(8, -104)

					4:
						weaponPos.position = Vector2(24, -112)

					5:
						weaponPos.position = Vector2(8, -104)

					6:
						weaponPos.position = Vector2(16, -88)

					7:
						weaponPos.position = Vector2(0, -64)

		elif front_dir == 2:
			weaponPos.position = Vector2(96.33, 77.76)

			if velocity.x < -speed * 0.9:
				animatedSprite.play("Run")
				match animatedSprite.frame:
					0:
						weaponPos.position = Vector2(-32, 0)

					1:
						weaponPos.position = Vector2(-8, -56)

					2:
						weaponPos.position = Vector2(-16, -64)

					3:
						weaponPos.position = Vector2(-8, -104)

					4:
						weaponPos.position = Vector2(-24, -112)

					5:
						weaponPos.position = Vector2(-8, -104)

					6:
						weaponPos.position = Vector2(-16, -88)

					7:
						weaponPos.position = Vector2(0, -64)

	else:
		on_ground = false

		if Input.is_action_pressed("player2_right") == false && Input.is_action_pressed("ui_left") == false:  #disable jump inertia
			if front_dir == 1:
				velocity.x -= FRICTION * delta
				if velocity.x < 0:
					velocity.x = 0
			elif front_dir == 2:
				velocity.x += FRICTION * delta
				if velocity.x > 0:
					velocity.x = 0

		if velocity.x == 0:
			animatedSprite.play("Jump")
		else:
			animatedSprite.play("Jump")

		if Input.is_action_pressed("player2_jump"):
			animatedSprite.play("Jump")
	
	weaponEffectParticle.emitting = on_ground

#press and change to attack state
	if Input.is_action_just_pressed("player2_attack"):
		state = ATTACK
		attackSound.play()
		attack_times += 1
		attaTimer.start()
		if attack_times > 2:
			attack_times = 1

func PlayerAttack(delta):
	weaponEffectParticle.emitting = true
	if on_ground == false:
		velocity.x = 0
		if attack_times <= 1:
			velocity.y = gravity * 0.01
		elif attack_times > 1:
			velocity.y += gravity * delta
	else:
		velocity = Vector2.ZERO
		#if Input.is_action_pressed("ui_right"):
		#	velocity.x = speed * 0.1
		#elif Input.is_action_pressed("ui_left"):
		#	velocity.x = -speed * 0.1
	
	playerHitbox.disabled = false
	velocity = move_and_slide(velocity, FLOOR)

	if front_dir == 1:
		if attack_times < 2:
			animatedSprite.play("Atta1")
			match animatedSprite.frame:					#set the position of weaponeffect
				0:
					weaponPos.position = Vector2(-53.503, 54.571)

				1:
					weaponPos.position = Vector2(151.789, -39.345)

				2:
					weaponPos.position = Vector2(109.315, -131.372)

				3:
					weaponPos.position = Vector2(-12.916, -150.722)

				4:
					weaponPos.position = Vector2(-97.865, -140.811)

				5:
					weaponPos.position = Vector2(-127.597, 70.144)
					playerHitbox.disabled = true
					state = MOVE

		elif attack_times == 2:
			animatedSprite.play("Atta2")
			match animatedSprite.frame:
				0:
					weaponPos.position = Vector2(-110.607, -66.245)

				1:
					weaponPos.position = Vector2(135.272, -23.299)

				2:
					weaponPos.position = Vector2(-4.894, 21.535)

				3:
					weaponPos.position = Vector2(-183.285, -24.243)

				4:
					weaponPos.position = Vector2(-221.984, -137.508)
					playerHitbox.disabled = true
					attack_times = 0
					state = MOVE

	elif front_dir == 2:
		if attack_times < 2:
			animatedSprite.play("Atta1")
			match animatedSprite.frame:
				0:
					weaponPos.position = Vector2(53.503, 54.571)

				1:
					weaponPos.position = Vector2(-151.789, -39.345)

				2:
					weaponPos.position = Vector2(-109.315, -131.372)

				3:
					weaponPos.position = Vector2(12.916, -150.722)

				4:
					weaponPos.position = Vector2(97.865, -140.811)

				5:
					weaponPos.position = Vector2(127.597, 70.144)
					playerHitbox.disabled = true
					state = MOVE

		elif attack_times == 2:
			animatedSprite.play("Atta2")
			match animatedSprite.frame:
				0:
					weaponPos.position = Vector2(110.607, -66.245)

				1:
					weaponPos.position = Vector2(-135.272, -23.299)

				2:
					weaponPos.position = Vector2(4.894, 21.535)

				3:
					weaponPos.position = Vector2(183.285, -24.243)

				4:
					weaponPos.position = Vector2(221.984, -137.508)
					playerHitbox.disabled = true
					attack_times = 0
					state = MOVE

	if Input.is_action_just_pressed("player2_dash"):				#dodge pressed
		playerHitbox.disabled = true
		state = DODGE
	
func PlayerDodge(_delta):
	weaponEffectParticle.emitting = true
	playerHurtboxDetect.start_invincibility(0.1)
	velocity = move_and_slide(velocity, FLOOR)
	animatedSprite.play("Dodge")
	weaponPos.position = Vector2(1.714, -19.051)
	
	if Input.is_action_pressed("player2_jump"):
		velocity.y = -dodge_power
		
	#elif Input.is_action_pressed("ui_down"):
	#	velocity.y = dodge_power
		
	else:
		if front_dir == 1:
			if Input.is_action_pressed("player2_jump"):
				velocity.y = -dodge_power
				velocity.x = dodge_power
			else:
				velocity.x = dodge_power

		elif front_dir == 2:
			if Input.is_action_pressed("player2_jump"):
				velocity.y = -dodge_power
				velocity.x = -dodge_power
			else:
				velocity.x = -dodge_power
			
	if animatedSprite.frame == 4:
		state = MOVE

	if Input.is_action_just_pressed("player2_attack"):
		state = ATTACK
		attackSound.play()
		attack_times += 1
		attaTimer.start()
		if attack_times > 2:
			attack_times = 1

func _on_Hurtbox_area_entered(area):
	if area.is_skill1 == true:
		$Stats.health -= 0.6 + PlayerStats.magical_damage * 0.15						#damage after being hurt by mobs
		playerHurtboxDetect.start_invincibility(1)	#time of invincibility after hurt
		var playerHurtEffect = PlayerHurtEffect.instance()
		get_parent().add_child(playerHurtEffect)
		playerHurtEffect.global_position = global_position
		area.get_parent().queue_free()
		
	else:
		$Stats.health -= PlayerStats.magical_damage * 0.9 + PlayerStats.physical_damage						#damage after being hurt by mobs
		playerHurtboxDetect.start_invincibility(1)	#time of invincibility after hurt
		var playerHurtEffect = PlayerHurtEffect.instance()
		get_parent().add_child(playerHurtEffect)
		playerHurtEffect.global_position = global_position

func _on_AttaTimer_timeout():
	attack_times -= 1

func self_respawn():
	state = DEAD


func _on_Skill_timeout():
	if skill_times < 1:
		skill_times += 1
