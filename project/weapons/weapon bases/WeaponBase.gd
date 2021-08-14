extends Node2D

signal shot
signal magazine_emptied(weapon_type)
signal ammo_changed(new_ammo)


enum WEAPON_TYPES {
	REVOLVER,
	TORCH
}
export(WEAPON_TYPES) var WEAPON_TYPE

export(PackedScene) var PROJ_BASIC: PackedScene = null
export(PackedScene) var PROJ_CRITICAL: PackedScene = null

export(int) var AMMO_DEFAULT: int = 6
export(int) var ammo: int = 6 setget set_ammo

export(bool) var shake_camera_when_shot: bool = true

export(AudioStream) var SHOOT_SOUND: AudioStream = null
export(AudioStream) var EMPTY_SOUND: AudioStream = null


func set_ammo(value):
	if ammo != value:
# warning-ignore:narrowing_conversion
		ammo = max(0, value)
		emit_signal("ammo_changed", ammo)
		if ammo == 0:
			emit_signal("magazine_emptied", WEAPON_TYPE)


func shoot_in_direction(direction: Vector2, spawn_pos: Vector2 = $ProjectilePos.global_position, proj_scene: PackedScene = PROJ_BASIC):
#	print("trying to shoot")
	if ammo > 0:
#		print("shot successful")
		if proj_scene:
			var projectile: Node2D = proj_scene.instance()
			get_tree().current_scene.add_child(projectile)
			projectile.global_position = spawn_pos
			projectile.rotation = direction.angle()
			
			projectile.hit_owner = get_parent()
		
		self.ammo -= 1
		emit_signal("shot")
		
		SfxPlayer.play_sfx(SHOOT_SOUND, get_tree().current_scene, Vector2(0.8, 1.1))
		if shake_camera_when_shot:
			get_tree().get_nodes_in_group("LevelCamera")[0].start_new_shake(2, 0.1)
	else:
		SfxPlayer.play_sfx(EMPTY_SOUND, get_tree().current_scene, Vector2(0.8, 1.1))
