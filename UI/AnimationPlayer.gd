extends AnimationPlayer

var is_anime_finished = false

func _ready():
	get_parent().get_node("white").modulate.a = 0

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "test_transit":
		is_anime_finished = true
