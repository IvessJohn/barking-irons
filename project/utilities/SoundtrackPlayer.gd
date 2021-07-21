extends Node

enum THEMES {
	MAIN_MENU,
	BATTLE
}
var TRACKS = {
	THEMES.MAIN_MENU: [preload("res://project/soundtracks/lassolady.ogg")],
	THEMES.BATTLE: [preload("res://project/soundtracks/City of Backstreet.ogg")]
}

var current_theme: int = THEMES.MAIN_MENU
var is_repeating: bool = true

onready var streamPlayer: AudioStreamPlayer = $AudioStreamPlayer


func play_soundtrack(theme: int, repeat_themes: bool = true):
	if current_theme != theme or !streamPlayer.playing:
		is_repeating = false # Prevent accidentally starting an old track playing
								# again when next command is stop()
		
		streamPlayer.stop()
		
		is_repeating = repeat_themes
		current_theme = theme
		
		var theme_tracks: Array = TRACKS[current_theme]
		if theme_tracks != []:
			streamPlayer.stream = theme_tracks[randi() % theme_tracks.size()]
			streamPlayer.play()

func replay_theme():
	streamPlayer.stream = TRACKS[current_theme][0]
	streamPlayer.play()

func _on_AudioStreamPlayer_finished():
	if is_repeating:
		replay_theme()
