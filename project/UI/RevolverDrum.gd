extends TextureRect

var bullets: int = 6 setget set_bullets # 6 bullets in a drum

export(AudioStream) var SOUND_SPIN: AudioStream = null


func set_bullets(value):
	if bullets != value:
# warning-ignore:narrowing_conversion
		bullets = max(0, value)
		for num in (6 - bullets):
			$Ammo.get_children()[-num].hide()

func spin_once():
#	$Tween.interpolate_property(self, "rect_rotation", (6 - (bullets + 1)) * 60, 
#			(6 - bullets) * 60, 0.1, Tween.TRANS_QUART, Tween.EASE_IN_OUT, 0.08)
	$Tween.interpolate_property(self, "rect_rotation", rect_rotation, 
			(6 - bullets) * 60, 0.1, Tween.TRANS_QUART, Tween.EASE_IN_OUT, 0.04)
	$Tween.start()
	
	yield(get_tree().create_timer(0.025), "timeout")
	SfxPlayer.play_sfx(SOUND_SPIN)
	if bullets == 0:
		yield($Tween, "tween_all_completed")
		hide()

func shot():
	self.bullets -= 1
	spin_once()
