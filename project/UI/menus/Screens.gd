extends Control


onready var mainMenu = get_tree().current_scene.get_node(".")


#--- GENERAL ---#
func return_to_main_menu():
	mainMenu.move_camera_to(mainMenu.CAM_POSITIONS["MAIN"])

func _on_ButCredits_pressed():
	mainMenu.move_camera_to(mainMenu.CAM_POSITIONS["CREDITS"])

#--- MAIN ---#
func _on_ButPlay_pressed():
	mainMenu.move_camera_to(mainMenu.CAM_POSITIONS["GAME_SELECTION"])


#--- GAME SELECTION ---#
func gamemode_chosen(mode: int):
	mainMenu.start_game(mode)


func _on_Duel_pressed():
	gamemode_chosen(Global.GAME_MODES.CASUAL_DUEL)


func _on_Arena_pressed():
	gamemode_chosen(Global.GAME_MODES.ARENA)


func update_mode_description(description_type: String):
	var modeHead = $GameSelection/ModeDescription/Mode.text
	var modeDescr = $GameSelection/ModeDescription/Description.text
	
	match description_type:
		"DUEL":
			modeHead = "DUEL"
			modeDescr = "1v1 match - show 'em who's better!"
		"ARENA":
			modeHead = "ARENA"
			modeDescr = "Fight for as long as you can!"
		"EMPTY":
			modeHead = ""
			modeDescr = ""
	
	$GameSelection/ModeDescription/Mode.text = modeHead
	$GameSelection/ModeDescription/Description.text = modeDescr
