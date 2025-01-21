extends TextureRect

var cooldown_time = 1
var timeleft = 0
onready var label = $Label
onready var textureProgress = $TextureProgress

func _ready():
	label.hide()
	textureProgress.value = 0
	textureProgress.texture_progress = texture
	timeleft = PlayerStats.dodgeCD_timeleft

func _process(_delta):
	$Label2.text = str(PlayerStats.dodge_times)
	
	if PlayerStats.dodge_times == PlayerStats.max_dodge_times:
		label.hide()
		textureProgress.value = 0

	else:
		timeleft = PlayerStats.dodgeCD_timeleft
		label.text = "%0.1f" % timeleft
		textureProgress.value = int((timeleft/cooldown_time) * 100)
		label.show()
		
		
