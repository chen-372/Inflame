extends Area2D

export var speed = 10.0
onready var smoketrail = $Smoketrail

var direction = Vector2()
var is_dead = false
var init_dir = 1

func _ready():
	init_dir = PlayerStats.playerFrontDir

func _physics_process(_delta):
	if !is_dead:
		position += direction * speed
		smoketrail.add_point(global_position)

func _on_Timer_timeout():
	if !is_dead:
		is_dead = true
		smoketrail.stop()
		speed = 0
		$AnimationPlayer.play("explosion")

func _on_Hitbox_area_entered(_area):
	var reflect_angel = 1
	if init_dir == 1:
		direction = Vector2.RIGHT.rotated(rand_range(-reflect_angel, reflect_angel))
	else:
		direction = Vector2.LEFT.rotated(rand_range(-reflect_angel, reflect_angel))
