extends "res://project/weapons/moving hitboxes/MovingHitbox.gd"

export(AudioStream) var SOUND: AudioStream = null


func _ready():
	SfxPlayer.play_sfx(SOUND, get_tree().current_scene, Vector2(0.8, 1.1))

func _on_Timer_timeout():
	queue_free()
