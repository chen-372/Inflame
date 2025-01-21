extends CanvasLayer

func _ready():
	set_visible(false)
	full_recover()

func _input(event):
	var name = get_tree().current_scene.name
	if event.is_action_pressed("ui_cancel") && name != "Start_Menu" && name != "Booting_Anime" && name != "All_Passed":
		set_visible(!get_tree().paused)
		get_tree().paused = !get_tree().paused

func _on_Continue_pressed():
	if get_tree().current_scene.name != "Start_Menu":
		get_tree().paused = false
		set_visible(false)
	
func set_visible(is_visible):
	for node in get_children():
		node.visible = is_visible

func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_Restart_pressed():
	set_visible(!get_tree().paused)
	get_tree().paused = !get_tree().paused
	restart()

func _on_Quit_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(GlobalSys.StartMenu)
	get_tree().paused = false
	set_visible(false)

func _on_ClearGameData_pressed():
	SaveSys.ClearGameData()

func restart():
	full_recover()
	if get_tree().current_scene.name == "PvP_Scene":
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scene/PvP_Scene.tscn")
		set_visible(false)
		get_tree().paused = false
		
	else:
		# warning-ignore:return_value_discarded
		get_tree().change_scene(SaveSys.load_game())
		
func full_recover():
	PlayerStats.health = PlayerStats.max_health
	PlayerStats.The_energy = 1
	PlayerStats.magical_damage = 0.3
	PlayerStats.physical_damage = 0.7
	PlayerStats.skill1_times = PlayerStats.max_skill1_times
	PlayerStats.dodge_times = PlayerStats.max_dodge_times

