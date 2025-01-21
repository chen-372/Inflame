extends Area2D

var invincible = false setget set_invincible

const HitEffect = preload("res://Effect/HitEffect.tscn")
const floating_text = preload("res://UI/FloatingText.tscn")

onready var playerStats = $"/root/PlayerStats"
onready var timer = $Timer
onready var collisionShape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position
	effect.emitting = true

func create_floating_text(damage_value, damage_type):
	var output_text = floating_text.instance()
	var main = get_tree().current_scene
	var spawn_range = 60
	
	output_text.set_as_toplevel(true)
	main.add_child(output_text)
	if damage_type == 3:
		output_text.is_true_damage = true
		spawn_range = 200
		
	output_text.global_position = global_position + Vector2(rand_range(-spawn_range, spawn_range), rand_range(-spawn_range, spawn_range))
	output_text.set_text(damage_value)
	output_text.set_text_color(damage_type)
	
func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func _on_Timer_timeout():
	self.invincible = false

func _on_Hurtbox_invincibility_started():
	collisionShape.set_deferred("disabled", true)

func _on_Hurtbox_invincibility_ended():
	collisionShape.disabled = false
