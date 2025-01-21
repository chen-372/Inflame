extends Node

var path = "user://save.json"
var file = File.new()
var saved_position = Vector2.ZERO

func _ready():
	pause_mode = PAUSE_MODE_PROCESS # This script can't get paused

func save_game(level_name, playerPosX, playerPosY):
	var save_json = File.new()
	var data: Dictionary = {
		"scene_to_load" : level_name,
		"playerPosX" : playerPosX,
		"playerPosY" : playerPosY
	}
	
	save_json.open(path, File.WRITE)
	save_json.store_line(to_json(data))
	file.close()
	
	saved_position = Vector2(playerPosX, playerPosY)

func load_game():
	var scene_to_load = ""
	var playerPosX = 0
	var playerPosY = 0
	
	if file.file_exists(path):
		file.open(path, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		
		scene_to_load = data["scene_to_load"]
		playerPosX = data["playerPosX"]
		playerPosY = data["playerPosY"]
	
		saved_position = Vector2(playerPosX, playerPosY)
	
	else:
		saved_position = Vector2.ZERO
		return "res://Scene/PreChapter/PreChapter.tscn"
	
	if scene_to_load == "":
		saved_position = Vector2.ZERO
		return "res://Scene/PreChapter/PreChapter.tscn"
		
	else:
		return scene_to_load

func ClearGameData():
	var save_json = File.new()
	var data: Dictionary = {
		"scene_to_load" : "",
		"playerPosX" : 0,
		"playerPosY" : 0
	}
	
	save_json.open(path, File.WRITE)
	save_json.store_line(to_json(data))
	file.close()
	
	print("Game data cleared.")
