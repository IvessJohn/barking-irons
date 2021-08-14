extends "res://project/weapons/moving hitboxes/MovingHitbox.gd"

export(AudioStream) var BREAK_SOUND: AudioStream = null

export(int) var ANGULAR_SPEED: int = 90

export(bool) var spawn_fire_when_broken: bool = true
export(PackedScene) var FIRE_SCENE: PackedScene = preload("res://project/objects/Fire.tscn")


func _process(delta):
	if cos(rotation) == 0:
		pass
	$Sprite.rotation_degrees += sign(cos(rotation)) * ANGULAR_SPEED * delta

func projectile_break():
	SfxPlayer.play_sfx(BREAK_SOUND)
	if spawn_fire_when_broken:
		var fire_pos: Vector2 = global_position
		Global.spawn_object_at_position(FIRE_SCENE, fire_pos)
	
	#play bullet impact effect
	queue_free()

func _on_BulletBase_area_entered(_area):
	projectile_break()


func _on_BulletBase_body_entered(body):
#	if !body.is_in_group("Entity"):
		projectile_break()
