extends Node

signal game_mode_changed(new_game_mode)

enum GAME_MODES {
	MENU,
	CASUAL,
	ARENA,
	LAN_MULTIPLAYER
}
var current_game_mode = GAME_MODES.MENU setget set_game_mode


func set_game_mode(value):
	if current_game_mode != value:
		current_game_mode = value
		emit_signal("game_mode_changed", current_game_mode)
