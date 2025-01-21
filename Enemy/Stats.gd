extends Node

export(float) var max_health = 1 setget set_max_health
var health = max_health setget set_health
export(float) var magical_resistance = 1
export(float) var physical_resistance = 1

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func _ready():
	self.health = max_health

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed")

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
