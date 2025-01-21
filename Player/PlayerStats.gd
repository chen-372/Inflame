extends Node

export(float) var max_health = 1.0 setget set_max_health
var health = max_health setget set_health

export(float) var The_energy = 0.0
var max_the_energy = 5.0

var max_dodge_times = 7
export(int) var dodge_times = max_dodge_times
var dodgeCD_timeleft = 0

var max_skill1_times = 1
export(int) var skill1_times = max_skill1_times
var skill1CD_timeleft = 0

var magical_damage = 0.3
var physical_damage = 0.7
var skill1_base_damage = 1.8
#export(float) var true_damage = 0   unused yet

var Tdamage_trigger = 3.7
var playerPosition = Vector2.ZERO
var playerFrontDir = 1
var weaponPosition = Vector2.ZERO
var on_ground = false
var in_fog = false
var sp_bullet_damage_rate = 1.5

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
	elif health >= max_health:
		health = max_health
