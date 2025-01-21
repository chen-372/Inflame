extends Control

onready var energyUIFull = $EnergyUIFull
onready var stats = get_parent().get_node("Stats")

func _process(_delta):
	if stats.health >= 0:
		energyUIFull.rect_size.x = stats.health * 326.4
