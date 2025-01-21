extends Control

onready var energyUIFull = $EnergyUIFull

func _process(_delta):
	if PlayerStats.The_energy >= 0:
		energyUIFull.rect_size.x = PlayerStats.The_energy * 326.4
		
	energyUIFull.modulate.g = PlayerStats.The_energy * 0.3		#change of effect color
