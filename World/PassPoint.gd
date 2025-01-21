extends Area2D

var player = 0

onready var playerDetect = $PlayerDetectionZone
export var nextLevel = ""		#destination

onready var playerDetectShape = $PlayerDetectionZone/CollisionShape2D
onready var levelTransitionAnime = get_parent().get_parent().get_node("LevelTransition").get_node("AnimationPlayer")

func _ready():
	playerDetectShape.disabled = true
	
func _physics_process(_delta):
	if get_parent().get_node("Enemy").get_child_count() == 0:
		playerDetectShape.disabled = false

		if playerDetect.player != null:
			player = playerDetect.player
			player.state = player.StandStill
			levelTransitionAnime.get_parent().get_node("white").global_position = player.global_position
			levelTransitionAnime.play("test_transit")
			get_parent().visible = false
			if levelTransitionAnime.is_anime_finished == true:
		# warning-ignore:return_value_discarded
				self.get_tree().change_scene(nextLevel)
				SaveSys.saved_position = Vector2.ZERO
