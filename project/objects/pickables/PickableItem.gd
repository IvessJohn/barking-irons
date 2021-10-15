extends Area2D

signal picked(picker)
signal destroyed


export(String) var PICKABLE_TYPE: String = "Item"

export(AudioStream) var PICK_SOUND: AudioStream = null
export(PackedScene) var PICK_EFFECT: PackedScene = null
export(AudioStream) var BREAK_SOUND: AudioStream = null


func pick_up(picker):
	emit_signal("picked", picker)
	if picker.is_in_group("Enemy"):
		picker.null_weaponItem()
	
	SfxPlayer.play_sfx(PICK_SOUND, get_tree().current_scene, Vector2(1.0,1.0), 1.0, PAUSE_MODE_PROCESS)
	#Pickup VFX
	
	queue_free()


func _on_Hurtbox_area_entered(area):
	if area.is_in_group("Projectile") and !area.is_in_group("Torch"):
		emit_signal("destroyed")
		
		SfxPlayer.play_sfx(BREAK_SOUND)
		
		queue_free()
