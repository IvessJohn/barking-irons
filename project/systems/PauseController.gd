extends Node


var can_toggle_pause: bool = true
export(bool) var show_pauseMenu: bool = true
export(NodePath) var pauseMenu = null

export(AudioStream) var SOUND_PAUSE: AudioStream = null
export(AudioStream) var SOUND_RESUME: AudioStream = null


func _input(_delta):
	if can_toggle_pause and Input.is_action_just_pressed("menu_pause"):
		var tree_paused = get_tree().paused
		if !tree_paused:
			pause()
		else:
			resume()

func pause(play_sound: bool = true, _start_menu: bool = true):
#	if start_menu and show_pauseMenu and pauseMenu:
		if play_sound:
			SfxPlayer.play_sfx(SOUND_PAUSE, self)
#		get_node(pauseMenu).animPlayer.play("popup")
		get_tree().set_deferred("paused", true)

func resume(play_sound: bool = true):
#	if show_pauseMenu and get_node(pauseMenu).visible:
		if play_sound:
			SfxPlayer.play_sfx(SOUND_RESUME, self)
#		get_node(pauseMenu).animPlayer.play("hide")
		get_tree().set_deferred("paused", false)

func trigger_damage_pause(pause_duration_ms: int = 35):
	pause(false, false)
	yield(get_tree().create_timer(pause_duration_ms * 0.001), "timeout")
	resume(false)
