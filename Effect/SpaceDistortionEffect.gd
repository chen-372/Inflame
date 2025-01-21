extends Node

onready var animationPlayer = $CanvasLayer/AnimationPlayer

func _physics_process(_delta):
	animationPlayer.play("Pulse")
