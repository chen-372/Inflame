extends Node

export var local_current_level = "unset"
#export var local_next_level = "unset" 		unused yet

func _ready():
	GlobalSys.currentLevel = local_current_level
	PlayerStats.skill1_times = PlayerStats.max_skill1_times
	PlayerStats.dodge_times = PlayerStats.max_dodge_times
