extends Node2D

onready var playerDetect = $PlayerDetectionZone
onready var label = $Label
export var entered_level = ""

func _ready():
	label.modulate.a = 0

func _process(delta):
	if playerDetect.player != null:
		if label.modulate.a < 1:
			label.modulate.a += delta * 1.5
		else:
			label.modulate.a = 1
	
		if Input.is_action_just_pressed("ui_accept"):
# warning-ignore:return_value_discarded
			get_tree().change_scene(entered_level)
	
	else:
		if label.modulate.a > 0:
			label.modulate.a -= delta * 1.5
		else:
			label.modulate.a = 0
