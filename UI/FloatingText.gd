extends Position2D

onready var label = $Label
onready var tween = $Tween

var text setget set_text, get_text
var velocity = Vector2(rand_range(-100, 100), -130)
var gravity = Vector2(0, 1.5)
var mass = 200
var is_true_damage = false

func _ready():
	if is_true_damage == false:
		tween.interpolate_property(self, "modulate",
		Color(modulate.r, modulate.g, modulate.b, modulate.a),
		Color(modulate.r, modulate.g, modulate.b, 0),
		0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.7
		)
		
		tween.interpolate_property(self, "scale",
		Vector2(0, 0),
		Vector2(1, 1),
		0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT
		)
		
		tween.interpolate_property(self, "scale",
		Vector2(1, 1),
		Vector2(0.4, 0.4),
		0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.7
		)
	else:
		tween.interpolate_property(self, "modulate",
		Color(modulate.r, modulate.g, modulate.b, modulate.a),
		Color(modulate.r, modulate.g, modulate.b, 0),
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.7
		)
		
		tween.interpolate_property(self, "scale",
		Vector2(0, 0),
		Vector2(3, 3),
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.7
		)
		
		tween.interpolate_property(self, "scale",
		Vector2(3, 3),
		Vector2(0.1, 0.1),
		0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.7
		)
		
	tween.start()
	
func _physics_process(delta):
	if is_true_damage == true:
		gravity.y *= -1
		
	velocity += gravity * mass * delta
	position += velocity * delta

func set_text_color(damage_type):
	if damage_type == 1:			#magical, blue
		self.modulate = Color("00dbff")

	elif damage_type == 2:			#physical, orange
		self.modulate = Color("ff8f00")
	
	if damage_type == 3:			#true damage, red
		self.modulate = Color("ff0000")

func set_text(input_text):
	if is_true_damage == false:
		label.text = str(int(-input_text * 100))
	else:
		label.text = str("TRUE DAMAGE = ", float(-input_text * 100))

func get_text():
	return label.text

func _on_Tween_tween_all_completed():
	get_tree().queue_delete(self)
