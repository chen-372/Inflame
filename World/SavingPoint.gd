extends Node2D

onready var playerDetect = $PlayerDetectionZone
onready var effectSaved = $MagicFire
onready var position2D = $Position2D

var saved = false

func _ready():
	effectSaved.modulate.a = 0

func _physics_process(delta):
	if playerDetect.player != null && saved == false:
		SaveSys.save_game(GlobalSys.currentLevel, position2D.global_position.x, position2D.global_position.y)
		saved = true
	
	if saved == true:
		if effectSaved.modulate.a < 1:
			effectSaved.modulate.a += delta
		else:
			effectSaved.modulate.a = 1
