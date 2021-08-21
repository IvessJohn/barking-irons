extends Node

signal acetime_active_changed(new_acetime)

export(bool) var acetime_allowed: bool = true

var acetime_active: bool = false setget set_acetime_active
var can_change_acetime_active: bool = true

export(float, 0.0, 1.0) var desired_time_modifier: float = 0.2

export(float) var time_active_max: float = 3.0
export(float) var time_active_left: float = time_active_max

export(float, 0.0, 1.0) var time_entering: float = 0.35
export(float, 0.0, 1.0) var time_leaving: float = 0.25
 
onready var durationTimer = $DurationTimer
onready var tween = $Tween


func set_acetime_active(value):
	if acetime_active != value:
		acetime_active = value
		emit_signal("acetime_active_changed", acetime_active)


func request_acetime_change():
	if not tween.is_active():
		if acetime_active:
			exit_acetime()
		else:
			enter_acetime()

func enter_acetime():	# A brief moment of entering Ace time (animation)
	if acetime_allowed:
		if can_change_acetime_active:
			tween.interpolate_property(Engine, "time_scale", Engine.time_scale,
					desired_time_modifier, time_entering,
					Tween.TRANS_BACK, Tween.EASE_IN_OUT)
			tween.interpolate_property(SoundtrackPlayer.streamPlayer, "pitch_scale", SoundtrackPlayer.streamPlayer.pitch_scale,
					0.5, time_entering,
					Tween.TRANS_BACK, Tween.EASE_IN_OUT)
			tween.start()
			yield(tween, "tween_completed")
		
		acetime_start()

func acetime_start():	# The actual start of Ace time
	Engine.time_scale = desired_time_modifier
	self.acetime_active = true
	durationTimer.start()

func acetime_stop():	# The actual stop of Ace time
	if acetime_active:
		self.acetime_active = false
		durationTimer.stop()
		
		exit_acetime()

func exit_acetime():	# A brief moment of exiting Ace time (animation)
	if can_change_acetime_active:
		tween.interpolate_property(Engine, "time_scale", Engine.time_scale,
				1.0, time_leaving,
				Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.interpolate_property(SoundtrackPlayer.streamPlayer, "pitch_scale", SoundtrackPlayer.streamPlayer.pitch_scale,
				1, time_entering,
				Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_completed")


func _on_DurationTimer_timeout():
	if acetime_active:
		acetime_stop()
