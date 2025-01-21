extends KinematicBody2D

var velocity = Vector2()
var target_position = position

func _physics_process(_delta):
	velocity = move_and_slide(velocity)
	$Sprite.flip_h = velocity.x < 0
	
	if is_on_ceiling() || is_on_floor() || is_on_wall():
		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
