extends KinematicBody2D

enum {
	MOVE,
	ATTACK,
	DODGE,
	SKILL1,
	#SKILL2,
	DEAD,
	StandStill
}

#ability related variables
var speed = 750
var jump_power = -1700
var dodge_power =2000
var gravity = 4600
var energy_loss_speed = 0
var energy_loss_base = 0.27

var velocity = Vector2.ZERO
var on_ground = true
var state = MOVE
var front_dir = 1   #facing_direc, 1 = right, 2 = left
var attack_times = 0
var jump_times = 1
var bullet_gather_limit = 7
var bullet_gather_times = 1
var bullet_spawn = [0, 0, 0, 0, 0]
var camzoom_factor = 1.1
var weaponEffectPos = Vector2.ZERO

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
onready var camera2D = get_parent().get_parent().get_node("Camera2D")

#soundeffects
onready var attackSound = $SoundEffect/Attack

const FRICTION = 4000
const FLOOR = Vector2(0, -1)
const PlayerHurtEffect = preload("res://Effect/PlayerHurtEffect.tscn")
const Skill1Bullet = preload("res://Player/Skill1Bullet.tscn")
const MotionDissolve = preload("res://Effect/MotionDissolve.tscn")
const Skill1ShockWaveEffect = preload("res://Player/Skill1ShockWaveEffect.tscn")

func _ready():
	randomize()
# warning-ignore:return_value_discarded
	PlayerStats.connect("no_health", self, "self_respawn")		#respawn after no health
	get_p_node("Enemy").position = Vector2(0, 0)
	camera2D.zoom = Vector2(2.2 * camzoom_factor, 2.2 * camzoom_factor)

	if SaveSys.saved_position != Vector2.ZERO:
		global_position = SaveSys.saved_position

func _physics_process(delta):							#main function
	
	#!!!! for debug !!!!
	#if Input.is_action_just_pressed("ui_focus_next"):
	#	debug_control()
	#!!!! for debug !!!!
	
	match state:
		MOVE:
			PlayerMotion(delta)

		ATTACK:
			PlayerAttack(delta)

		DODGE:
			PlayerDodge(delta)

		SKILL1:
			PlayerSkill1(delta)

		#SKILL2:
		#	pass

		DEAD:
			visible = false
			playerHurtbox.disabled = true
			collisionShape.disabled = true
			playerHitbox.disabled = true
			modulate.a -= delta * 0.5
			if modulate.a <= 0:
				Pause.restart()

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

	PlayerStats.weaponPosition = weaponPos.global_position
	PlayerStats.playerPosition = global_position
	PlayerStats.playerFrontDir = front_dir
	PlayerStats.on_ground = on_ground
	EnergyTransformation(delta)

	PlayerStats.skill1CD_timeleft = $Skill1_CD.time_left
	if PlayerStats.skill1_times >= PlayerStats.max_skill1_times:
		PlayerStats.skill1_times = PlayerStats.max_skill1_times

	PlayerStats.dodgeCD_timeleft = $Dodge_CD.time_left
	if PlayerStats.dodge_times >= PlayerStats.max_dodge_times:
		PlayerStats.dodge_times = PlayerStats.max_dodge_times
		$Dodge_CD.paused = true
	else:
		$Dodge_CD.paused = false

	if Input.is_action_just_pressed("skill1_forward") && get_p_node("PlayerBullet").get_child_count() >= bullet_gather_limit && bullet_gather_times >= 1:
		var skill1ShockWaveEffect = Skill1ShockWaveEffect.instance()
		get_parent().add_child(skill1ShockWaveEffect)

		skill1ShockWaveEffect.global_position.y = global_position.y
		if front_dir == 1:
			skill1ShockWaveEffect.global_position.x = global_position.x + 150
		else:
			skill1ShockWaveEffect.global_position.x = global_position.x - 150

		if camera2D.zoom.x > 2.6 * camzoom_factor:
			camera_zooming(1.5, 2.6, 2, delta)
		elif camera2D.zoom.x < 2.6 * camzoom_factor:
			camera_zooming(1.5, 2.6, 1, delta)

		bullet_gather_times -= 1

	if get_p_node("PlayerBullet").get_child_count() >= 18:			#prevent too much bullets
		for elem in range(3):
			get_p_node("PlayerBullet").get_child(elem).get_node("Tween").start()

	if get_p_node("Magifog").get_child_count() >= 5:					#prevent too much fog
		get_p_node("Magifog").get_child(0).queue_free()

func PlayerMotion(delta):
	energy_loss_speed = energy_loss_base * 0.2
	velocity = move_and_slide(velocity, FLOOR)		#enable motions
	velocity.y += gravity * delta 					#enable gravity
	if position.y > 4000:							#dealth for fall
		Pause.restart()
	bullet_spawn = [0, 0, 0, 0, 0]

	if abs(velocity.x) > 1 || abs(velocity.y) > 100:
		if camera2D.zoom.x > 2.4 * camzoom_factor:
			camera_zooming(0.2, 2.4, 2, delta)
		elif camera2D.zoom.x < 2.4 * camzoom_factor:
			camera_zooming(0.2, 2.4, 1, delta)

	elif abs(velocity.x) < 1 && abs(velocity.y) < 100:
		if camera2D.zoom.x > 2.2 * camzoom_factor:
			camera_zooming(0.1, 2.2, 2, delta)
		elif camera2D.zoom.x < 2.2 * camzoom_factor:
			camera_zooming(0.1, 2.2, 1, delta)

	var phpx = playerHitbox.position.x
	var cspx = collisionShape.position.x
	if front_dir == 1:
		animatedSprite.flip_h = false
		playerHitbox.position.x = -abs(phpx)
		collisionShape.position.x = -abs(cspx)
		playerHurtbox.position.x = -abs(cspx)
	elif front_dir == 2:
		animatedSprite.flip_h = true
		playerHitbox.position.x = abs(phpx)
		collisionShape.position.x = abs(cspx)
		playerHurtbox.position.x = abs(cspx)

	#Hmotion
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		front_dir = 1

	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		front_dir = 2

	else:
		if velocity.x > 0 && on_ground == true:
			animatedSprite.play("Brake")
			match animatedSprite.frame:
					0:
						weaponPos.position = Vector2(-68.13, 37.58)

					1:
						weaponPos.position = Vector2(-108.74, 84.22)

					2:
						weaponPos.position = Vector2(-108.74, 84.22)

					3:
						weaponPos.position = Vector2(-113.44, 78.17)

					4:
						weaponPos.position = Vector2(-136.56, 79.11)


			velocity.x -= FRICTION * delta			#friction applied
			if velocity.x < 0:
				velocity.x = 0

		elif velocity.x < 0 && on_ground == true:
			animatedSprite.play("Brake")
			match animatedSprite.frame:
					0:
						weaponPos.position = Vector2(68.13, 37.58)

					1:
						weaponPos.position = Vector2(108.74, 84.22)

					2:
						weaponPos.position = Vector2(108.74, 84.22)

					3:
						weaponPos.position = Vector2(113.44, 78.17)

					4:
						weaponPos.position = Vector2(136.56, 79.11)

			velocity.x += FRICTION * delta
			if velocity.x > 0:
				velocity.x = 0

	if Input.is_action_just_pressed("ui_dodge"):				#dodge pressed
		if PlayerStats.dodge_times > 0:
			PlayerStats.dodge_times -= 1
			state = DODGE
			#$Dodge_CD.start()

#Vmotion
	if Input.is_action_just_pressed("ui_jump"):
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

		if Input.is_action_pressed("ui_right") == false && Input.is_action_pressed("ui_left") == false:  #disable jump inertia
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

		if Input.is_action_pressed("ui_jump"):
			animatedSprite.play("Jump")

	weaponEffectParticle.emitting = on_ground

#skill 1
	if Input.is_action_just_pressed("ui_skill1"):
		if PlayerStats.skill1_times == 1:
			state = SKILL1
			playerHurtboxDetect.start_invincibility(0.5)
			PlayerStats.skill1_times -= 1
			PlayerStats.The_energy -= 0.25
			$Skill1_CD.start()
			if bullet_gather_times < 1:
				bullet_gather_times = 1

#press and change to attack state
	if Input.is_action_just_pressed("ui_attack"):
		state = ATTACK
		attackSound.play()
		attack_times += 1
		attaTimer.start()
		if attack_times > 2:
			attack_times = 1
		
func PlayerAttack(delta):
	energy_loss_speed = energy_loss_base
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

	if attack_times >= 1:
		if camera2D.zoom.x > 2.1 * camzoom_factor:
			camera_zooming(0.2, 2.1, 2, delta)
		elif camera2D.zoom.x < 2.1 * camzoom_factor:
			camera_zooming(0.2, 2.1, 1, delta)

	playerHitbox.disabled = false
	velocity = move_and_slide(velocity, FLOOR)

	if front_dir == 1:
		if attack_times < 2:
			animatedSprite.play("Atta1")
			match animatedSprite.frame:					#set the position of weaponeffect
				0:
					weaponPos.position = Vector2(-53.50, 54.57)

				1:
					weaponPos.position = Vector2(151.79, -39.35)

				2:
					weaponPos.position = Vector2(109.32, -131.37)

				3:
					weaponPos.position = Vector2(-12.92, -150.72)

				4:
					weaponPos.position = Vector2(-97.87, -140.81)

				5:
					weaponPos.position = Vector2(-127.60, 70.14)
					playerHitbox.disabled = true
					state = MOVE

		elif attack_times == 2:
			animatedSprite.play("Atta2")
			match animatedSprite.frame:
				0:
					weaponPos.position = Vector2(-110.61, -66.25)

				1:
					weaponPos.position = Vector2(135.27, -23.3)

				2:
					weaponPos.position = Vector2(-4.89, 21.54)

				3:
					weaponPos.position = Vector2(-183.29, -24.24)

				4:
					weaponPos.position = Vector2(-221.98, -137.51)
					playerHitbox.disabled = true
					attack_times = 0
					state = MOVE

	elif front_dir == 2:
		if attack_times < 2:
			animatedSprite.play("Atta1")
			match animatedSprite.frame:
				0:
					weaponPos.position = Vector2(53.50, 54.57)

				1:
					weaponPos.position = Vector2(-151.79, -39.35)

				2:
					weaponPos.position = Vector2(-109.32, -131.37)

				3:
					weaponPos.position = Vector2(12.92, -150.72)

				4:
					weaponPos.position = Vector2(97.87, -140.81)

				5:
					weaponPos.position = Vector2(127.6, 70.14)
					playerHitbox.disabled = true
					state = MOVE

		elif attack_times == 2:
			animatedSprite.play("Atta2")
			match animatedSprite.frame:
				0:
					weaponPos.position = Vector2(110.61, -66.25)

				1:
					weaponPos.position = Vector2(-135.27, -23.3)

				2:
					weaponPos.position = Vector2(4.89, 21.54)

				3:
					weaponPos.position = Vector2(183.29, -24.24)

				4:
					weaponPos.position = Vector2(221.98, -137.51)
					playerHitbox.disabled = true
					attack_times = 0
					state = MOVE

	if Input.is_action_just_pressed("ui_dodge"):				#dodge pressed
		playerHitbox.disabled = true
		#$Dodge_CD.start()
		if PlayerStats.dodge_times > 0:
			PlayerStats.dodge_times -= 1
			state = DODGE

func PlayerDodge(delta):
	energy_loss_speed = energy_loss_base
	weaponEffectParticle.emitting = true
	playerHurtboxDetect.start_invincibility(0.1)
	velocity = move_and_slide(velocity, FLOOR)
	animatedSprite.play("Dodge")
	weaponPos.position = Vector2(1.71, -19.05)

	if camera2D.zoom.x > 2.5 * camzoom_factor:
		camera_zooming(0.5, 2.5, 2, delta)
	elif camera2D.zoom.x < 2.5 * camzoom_factor:
		camera_zooming(0.5, 2.5, 1, delta)

	if Input.is_action_pressed("ui_up"):
		velocity.y = -dodge_power

	elif Input.is_action_pressed("ui_down"):
		velocity.y = dodge_power

	else:
		if front_dir == 1:
			if Input.is_action_pressed("ui_up"):
				velocity.y = -dodge_power
				velocity.x = dodge_power
			else:
				velocity.x = dodge_power

		elif front_dir == 2:
			if Input.is_action_pressed("ui_up"):
				velocity.y = -dodge_power
				velocity.x = -dodge_power
			else:
				velocity.x = -dodge_power

	if animatedSprite.frame == 4:
		state = MOVE

	if Input.is_action_just_pressed("ui_attack"):
		state = ATTACK
		attackSound.play()
		attack_times += 1
		attaTimer.start()
		if attack_times > 2:
			attack_times = 1
		
func PlayerSkill1(delta):
	energy_loss_speed = energy_loss_base
	weaponEffectParticle.emitting = true

	if camera2D.zoom.x > 2.6 * camzoom_factor:
		camera_zooming(1.5, 2.6, 2, delta)
	elif camera2D.zoom.x < 2.6 * camzoom_factor:
		camera_zooming(1.5, 2.6, 1, delta)
	
	if front_dir == 1:
		weaponPos.position = Vector2(-96.33, 77.76)
	elif front_dir == 2:
		weaponPos.position = Vector2(96.33, 77.76)
	
	for elem in range(5):
		if abs(velocity.x) < 10 && abs(velocity.y) < 100:
			spawn_skill1Bullet(elem, weaponPos.global_position)
		else:
			spawn_skill1Bullet(elem, position)
		if elem == 4:
			state = MOVE

func spawn_skill1Bullet(index, pos):
	if bullet_spawn[index] < 1:
		var skill1Bullet = Skill1Bullet.instance()
		get_p_node("PlayerBullet").add_child(skill1Bullet)
		skill1Bullet.global_position = pos
		bullet_spawn[index] = 1

func EnergyTransformation(delta):
	if PlayerStats.The_energy <= 0:
		PlayerStats.The_energy = 0

	else:
		if PlayerStats.The_energy < 2:
			PlayerStats.The_energy -= energy_loss_speed * delta
			PlayerStats.magical_damage = PlayerStats.The_energy * 1.05 + 0.3

		elif PlayerStats.The_energy >= 2 && PlayerStats.The_energy < 3:
			PlayerStats.The_energy -= energy_loss_speed * 1.6 * delta
			PlayerStats.magical_damage = PlayerStats.The_energy * 1.01 + 0.3

		elif PlayerStats.The_energy >= 3 && PlayerStats.The_energy < PlayerStats.Tdamage_trigger:
			PlayerStats.The_energy -= energy_loss_speed * 2.4 * delta
			PlayerStats.magical_damage = PlayerStats.The_energy * 1 + 0.3

		elif PlayerStats.The_energy >= PlayerStats.Tdamage_trigger:
			PlayerStats.The_energy -= energy_loss_speed * 8 * delta
			PlayerStats.magical_damage = 4

			if PlayerStats.The_energy >= PlayerStats.max_the_energy:
				PlayerStats.The_energy = PlayerStats.max_the_energy

	weaponEffect.modulate.b = 1 - PlayerStats.The_energy * 0.4				#change of color after absorbing
	weaponEffect.modulate.g = 1 + PlayerStats.The_energy * 0.3
	weaponEffect.modulate.a = 1.3 + PlayerStats.The_energy * 0.2

	if PlayerStats.The_energy < PlayerStats.Tdamage_trigger:
		property_change(60, 50, 80)
	else:
		property_change(80, 70, 100)

func property_change(sv, jv, dv):
	speed = PlayerStats.The_energy * sv + 750										#added abilities after absorbing
	jump_power = -PlayerStats.The_energy * jv -1700
	dodge_power = PlayerStats.The_energy * dv + 1300

func camera_zooming(camzoom_speed, zoom_limit, zoom_dir, delta):		#1: zoom out, 2: zoom in
	if zoom_dir == 1:
		camera2D.zoom.x += camzoom_speed * delta
		camera2D.zoom.y += camzoom_speed * delta
		if camera2D.zoom >= Vector2(zoom_limit * camzoom_factor, zoom_limit * camzoom_factor):
			camera2D.zoom = Vector2(zoom_limit * camzoom_factor, zoom_limit * camzoom_factor)

	elif zoom_dir == 2:
		camera2D.zoom.x -= camzoom_speed * delta
		camera2D.zoom.y -= camzoom_speed * delta
		if camera2D.zoom <= Vector2(zoom_limit * camzoom_factor, zoom_limit * camzoom_factor):
			camera2D.zoom = Vector2(zoom_limit * camzoom_factor, zoom_limit * camzoom_factor)

func _on_Hurtbox_area_entered(area):
	PlayerStats.health -= area.enemy_damage						#damage after being hurt by mobs
	playerHurtboxDetect.start_invincibility(1)	#time of invincibility after hurt
	var playerHurtEffect = PlayerHurtEffect.instance()
	get_parent().add_child(playerHurtEffect)
	playerHurtEffect.global_position = global_position

func _on_AttaTimer_timeout():
	attack_times -= 1

func _on_Dodge_CD_timeout():
	PlayerStats.dodge_times += 1

func _on_Skill1_CD_timeout():
	PlayerStats.skill1_times += 1

func self_respawn():
	state = DEAD

func debug_control():
	PlayerStats.health = PlayerStats.max_health
	PlayerStats.skill1_times = PlayerStats.max_skill1_times
	PlayerStats.The_energy = 4.99
	PlayerStats.dodge_times = PlayerStats.max_dodge_times
	
	print("the energy = ", PlayerStats.The_energy)
	print("skill1_times = ", PlayerStats.skill1_times)
	print("dodge times = ", PlayerStats.dodge_times)
	print("magical damage = ", PlayerStats.magical_damage)
	print("-------------------------<Godot built-in editor sucks>")
	print("speed = ", speed)
	print("jump power = ", jump_power)

func _on_MotionDissolve_timeout():
	if state == DEAD:
		return

	if PlayerStats.The_energy > PlayerStats.Tdamage_trigger && (velocity.x != 0 || state == ATTACK || on_ground == false):
		var motionDissolve = MotionDissolve.instance()
		get_parent().add_child(motionDissolve)
		get_parent().move_child(motionDissolve, get_index())

		var properties = [
			"frames",
			"animation",
			"frame",
			"flip_h",
			"scale",
			"modulate",
			"global_position"
		]

		for name in properties:
			motionDissolve.set(name, animatedSprite.get(name))

	else:
		return

func _on_InFogState_timeout():
	if PlayerStats.in_fog:
		PlayerStats.in_fog = false

func get_p_node(node_name):
	return get_parent().get_node(node_name)
