extends Node2D

export(Array) var LEVELS_ARRAY: Array = [
	"res://project/levels/Level1.tscn",
	"res://project/levels/Level2.tscn",
	"res://project/levels/Level3.tscn"
]

onready var player = $Player
onready var battleUI = $UI/BattleUI
onready var messageShower = $UI/MessageShower
onready var finalScreen = $UI/FinalScreen

var player_shot_himself: bool = false


func _ready():
	randomize()
	connect_ui_elements()
	SoundtrackPlayer.play_soundtrack(SoundtrackPlayer.THEMES.BATTLE)
	SoundtrackPlayer.streamPlayer.volume_db = 0

func connect_ui_elements():
	# Revolver drum
	var drumUI = $UI/BattleUI.revolverDrum
	player.revolver.connect("shot", drumUI, "shot")
	player.connect("picked_revolver", drumUI, "show")
	player.revolver.connect("magazine_emptied", drumUI, "hide")


func _on_RevolverItem_picked(picker_object: Node2D):
	var picker_name: String = ""
	if picker_object.is_in_group("Player"):
		picker_name = "Player"
	elif picker_object.is_in_group("Enemy"):
		picker_name = "Enemy"
	messageShower.show_message("ROD CLAIMED", "by " + picker_name)

func game_end():
	var entities = get_tree().get_nodes_in_group("Entity")
	for e in entities:
		e.set_deferred("can_move", false)

func _on_Player_died():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for e in enemies:
		e.set_deferred("player", null)
#		e.set_deferred("FOLLOWS_PATH", false)
		e.set_deferred("can_move", false)
	
	if !player_shot_himself:
		finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.DEFEAT, "You were killed.")
	else:
		finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.DEFEAT, "You have just shot yourself. Genius.")
	game_end()


func _on_CheatBorders_body_entered(body):
	if body.is_in_group("Player"):
		finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "You have fled from the battlefield - not a bug, it's a feature.")
		game_end()
	elif body.is_in_group("Enemy"):
		finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "You have literally pushed him out!")
		game_end()


func _on_RevolverItem_destroyed():
	finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "Gun broken. No gun - no fight.")
	game_end()


func _on_EnemyBase_died():
	if player != null and !player.moved_while_paused:
		finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "Fair win.")
	else:
		finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "You didn't control time, did you?")
	game_end()

func start_new_level():
	randomize()
	var found_next_level = false
	if LEVELS_ARRAY.size() > 0:
		var next_level: String = LEVELS_ARRAY[randi() % LEVELS_ARRAY.size()]
		if next_level != "":
# warning-ignore:return_value_discarded
			get_tree().change_scene(next_level)
			found_next_level = true
	if !found_next_level:
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()


func _on_FinalScreen_request_new_level():
	start_new_level()


func _on_Player_shot_himself():
	finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.DEFEAT, "You have just shot yourself. Genius.")
	game_end()
	pass
