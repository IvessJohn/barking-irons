extends Control

enum MENU_STATES {
	WAITING,	# The "Press any key" screen is shown
	ACTIVE		# Meaning it is launched
}
var cur_menu_state = MENU_STATES.WAITING

enum MENUS {
	MAIN,
	PLAY,
	CREDITS
}
var current_menu = MENUS.MAIN setget set_current_menu
onready var CAM_POSITIONS: Dictionary = {
	"MAIN": $Screens/Main/Center.global_position,
	"GAME_SELECTION": $Screens/GameSelection/Center.global_position,
	"CREDITS": $Screens/Credits/Center.global_position
}

onready var animPlayer = $AnimationPlayer
onready var camera = $Camera2D
onready var camTween = $Camera2D/Tween
var cur_camTween_targetpos: Vector2 = Vector2.ZERO
onready var gameSelNode = $Screens/GameSelection


func _ready():
	randomize()
	yield(get_tree(), "idle_frame")
	if Global.just_launched:
#	if false:
		show_wait_menu()
		Global.just_launched = false

func _process(delta):
	if cur_menu_state == MENU_STATES.WAITING:
#		if Input.is_action_just_pressed()
		pass

func _input(event):
	if event is InputEventKey and event.pressed:
		if cur_menu_state == MENU_STATES.WAITING:
			sequence_launch()

func show_wait_menu():
	cur_menu_state = MENU_STATES.WAITING
	$Screens.hide()
	$PressKeyToStartScreen.show()

func sequence_launch():
	cur_menu_state = MENU_STATES.ACTIVE
	animPlayer.play("launch")

func start_game(gamemode: int):
	var levels_array: Array = []
	
	if gamemode in Global.GAME_MODES.values():
		levels_array = Global.LEVEL_ARRAYS_DICT[gamemode]
		
		if levels_array.size() > 0:
			levels_array.shuffle()
			var level = levels_array[0]
			get_tree().change_scene(level)
			return
		else:
			print("level array size = 0")


func set_current_menu(new_menu: int):
	match new_menu:
		MENUS.MAIN:
			# Main screen
			$Screens/Main/VBoxContainer/Menu/ButPlay.set_disabled(false)
			$Screens/Main/VBoxContainer/Menu/ButCredits.set_disabled(false)
			$Screens/Main/VBoxContainer/Menu/ButQuit.set_disabled(false)
			# Game selection screen
			$Screens/GameSelection/Modes/Duel.set_disabled(true)
			$Screens/GameSelection/Modes/Arena.set_disabled(true)
			$Screens/GameSelection/Modes/Back.set_disabled(true)
			# Credits screen
			$Screens/Credits/VBoxContainer/Back.set_disabled(true)
		MENUS.PLAY:
			# Main screen
			$Screens/Main/VBoxContainer/Menu/ButPlay.set_disabled(true)
			$Screens/Main/VBoxContainer/Menu/ButCredits.set_disabled(true)
			$Screens/Main/VBoxContainer/Menu/ButQuit.set_disabled(true)
			# Game selection screen
			$Screens/GameSelection/Modes/Duel.set_disabled(false)
			$Screens/GameSelection/Modes/Arena.set_disabled(false)
			$Screens/GameSelection/Modes/Back.set_disabled(false)
			# Credits screen
			$Screens/Credits/VBoxContainer/Back.set_disabled(true)
		MENUS.CREDITS:
			# Main screen
			$Screens/Main/VBoxContainer/Menu/ButPlay.set_disabled(true)
			$Screens/Main/VBoxContainer/Menu/ButCredits.set_disabled(true)
			$Screens/Main/VBoxContainer/Menu/ButQuit.set_disabled(true)
			# Game selection screen
			$Screens/GameSelection/Modes/Duel.set_disabled(true)
			$Screens/GameSelection/Modes/Arena.set_disabled(true)
			$Screens/GameSelection/Modes/Back.set_disabled(true)
			# Credits screen
			$Screens/Credits/VBoxContainer/Back.set_disabled(false)

func move_camera_to(new_cam_pos: Vector2):
	if new_cam_pos != cur_camTween_targetpos:
		cur_camTween_targetpos = new_cam_pos
	
		camTween.stop_all()
		camTween.interpolate_property(camera, "global_position", camera.global_position,
				cur_camTween_targetpos, 0.1, Tween.TRANS_CIRC, Tween.EASE_IN_OUT, 0.025)
		camTween.start()


func _on_TESTTimer_timeout():
	start_game(Global.GAME_MODES.CASUAL_DUEL)
