extends Control

var save_scene = "unset"
onready var menu = $AnimatedSprite

func _ready():
	menu.frame = 0

func _on_Play_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(SaveSys.load_game())
	
func _on_Exit_pressed():
	$Exit.visible = false
	get_tree().quit()

func _on_ClearGameData_pressed():
	SaveSys.ClearGameData()

func _on_Play_mouse_entered():
	menu.frame = 1

func _on_Play_mouse_exited():
	menu.frame = 0

func _on_Exit_mouse_entered():
	menu.frame = 2

func _on_Exit_mouse_exited():
	menu.frame = 0

func _on_PvP_Mode_dev_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scene/PvP_Scene.tscn")
