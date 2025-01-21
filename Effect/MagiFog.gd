extends Area2D

onready var fogEffect = $Particles2D
onready var playerDetectionZone = $FogPlayerDetectionZone
onready var timer = $Timer

var can_be_absorbed = false

func _physics_process(delta):
	if playerDetectionZone.can_see_player() && can_be_absorbed == true:
		var playerDetect = playerDetectionZone.player
		if playerDetect != null:
			fogEffect.modulate.a -= 1.9 * delta
			fogEffect.modulate.b -= 3 * delta

			if PlayerStats.The_energy < PlayerStats.max_the_energy:
				PlayerStats.The_energy += 2.5 * delta			#amount of energy for each fog
			elif PlayerStats.The_energy == PlayerStats.max_the_energy:
				PlayerStats.health -= 8 * delta
		
			if fogEffect.modulate.a <= 0:
				if PlayerStats.dodge_times < PlayerStats.max_dodge_times:
					PlayerStats.dodge_times += 1
				PlayerStats.skill1_times = PlayerStats.max_skill1_times
	
	if fogEffect.modulate.a <= 0 || fogEffect.emitting == false:
		queue_free()
	
	if playerDetectionZone.can_see_player():
		PlayerStats.in_fog = true
	
func _on_Timer_timeout():			#wait time for fog available to be absorbed
	can_be_absorbed = true
