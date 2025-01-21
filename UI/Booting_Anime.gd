extends Control

func _ready():
	$AnimationPlayer.play("Booting")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Booting":
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://UI/Start_Menu.tscn")
