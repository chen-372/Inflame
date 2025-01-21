extends Node2D

onready var label = $Label

func _ready():
	label.modulate.a = 0

func _process(delta):
	if $PlayerDetectionZone.player != null:
		if label.modulate.a < 1:
			label.modulate.a += delta * 1.5
		else:
			label.modulate.a = 1
		
		if Input.is_action_just_pressed("ui_accept"):
			PlayerStats.health = PlayerStats.max_health
			PlayerStats.The_energy = 3.7
	
	else:
		if label.modulate.a > 0:
			label.modulate.a -= delta * 1.5
		else:
			label.modulate.a = 0
