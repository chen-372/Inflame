extends Particles2D

func _physics_process(_delta):
	if emitting == false:
		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
