extends MarginContainer


onready var mainMenu = get_tree().current_scene.find_node("MainMenu")

func gamemode_chosen(mode: int):
	mainMenu.start_game(mode)


func _on_Duel_pressed():
	gamemode_chosen(Global.GAME_MODES.CASUAL_DUEL)


func _on_Arena_pressed():
	gamemode_chosen(Global.GAME_MODES.ARENA)
