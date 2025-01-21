extends TextureRect

var cooldown_time = 10			#equal to player cd, mannually change required
var timeleft = 0
onready var label = $Label
onready var textureProgress = $TextureProgress

func _ready():
	label.hide()
	textureProgress.value = 0
	textureProgress.texture_progress = texture
	timeleft = PlayerStats.skill1CD_timeleft

func _process(_delta):
	if PlayerStats.skill1_times == PlayerStats.max_skill1_times:
		label.hide()
		textureProgress.value = 0
	
	else:
		timeleft = PlayerStats.skill1CD_timeleft
		label.text = "%0.1f" % timeleft
		textureProgress.value = int((timeleft/cooldown_time) * 100)
		label.show()
		
		
