extends "res://project/weapons/moving hitboxes/MovingHitbox.gd"

export(int) var durability: int = 1 setget set_durability
export(AudioStream) var BREAK_SOUND: AudioStream = null


func set_durability(value):
# warning-ignore:narrowing_conversion
	durability = max(0, value)
	if durability == 0:
		projectile_break()


func projectile_break():
	SfxPlayer.play_sfx(BREAK_SOUND)
	#play bullet impact effect
	queue_free()

func _on_BulletBase_area_entered(_area):
	projectile_break()


func _on_BulletBase_body_entered(body):
	if !body.is_in_group("Entity"):
		projectile_break()
