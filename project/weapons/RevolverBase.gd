extends Node2D

signal shot
signal magazine_emptied
signal bullets_changed(new_bullets)

export(PackedScene) var BULLET_BASIC: PackedScene = null
export(PackedScene) var BULLET_CRITICAL: PackedScene = null

export(int) var BULLETS_DEFAULT: int = 6
export(int) var bullets: int = 6 setget set_bullets

export(AudioStream) var SHOOT_SOUND: AudioStream = null
export(AudioStream) var EMPTY_SOUND: AudioStream = null


func set_bullets(value):
	if bullets != value:
# warning-ignore:narrowing_conversion
		bullets = max(0, value)
		emit_signal("bullets_changed", bullets)
		if bullets == 0:
			emit_signal("magazine_emptied")


func shoot_in_direction(direction: Vector2, spawn_pos: Vector2 = $BulletPos.global_position, bullet_scene: PackedScene = BULLET_BASIC):
#	print("trying to shoot")
	if bullets > 0:
#		print("shot successful")
		if bullet_scene:
			var bullet: Node2D = bullet_scene.instance()
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = spawn_pos
			bullet.rotation = direction.angle()
			
			var bullet_group_name = "Bullet"
			if get_parent().is_in_group("Player"):
				bullet_group_name = "Player" + bullet_group_name
			elif get_parent().is_in_group("Enemy"):
				bullet_group_name = "Enemy" + bullet_group_name
			bullet.add_to_group(bullet_group_name)
			print("Bullet group: " + bullet_group_name)
		
		self.bullets -= 1
		emit_signal("shot")
		
		SfxPlayer.play_sfx(SHOOT_SOUND, get_tree().current_scene, Vector2(0.8, 1.1))
		get_tree().get_nodes_in_group("LevelCamera")[0].start_new_shake(2, 0.1)
	else:
		SfxPlayer.play_sfx(EMPTY_SOUND, get_tree().current_scene, Vector2(0.8, 1.1))
