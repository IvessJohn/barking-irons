extends StaticBody2D


signal hp_changed(new_hp)
signal got_hit(damage)
signal hp_max_changed(new_hp_max)
signal destroyed(object)

export(PackedScene) var DAMAGE_EFFECT: PackedScene = null
export(PackedScene) var DESTROY_EFFECT: PackedScene = null

export(AudioStream) var DAMAGE_SOUND: AudioStream = null
export(AudioStream) var DESTROY_SOUND: AudioStream = null

export(int) var hp_max: int = 100 setget set_hp_max
export(int) var hp: int = 100 setget set_hp, get_hp
export(bool) var invincible: bool = false
var is_dead: bool = false

onready var statusEffectHandler = $StatusEffectHandler
onready var firePosition = $FirePosition


### SETTERS AND GETTERS

func set_hp_max(value):
	if hp_max != value:
# warning-ignore:narrowing_conversion
		hp_max = max(0, value)
		self.hp = hp
		emit_signal("hp_max_changed", hp_max)

func set_hp(value):
# warning-ignore:narrowing_conversion
	if value < hp:
		emit_signal("got_hit", hp - value)
	
	hp = clamp(value, 0, hp_max)
	emit_signal("hp_changed", hp)
	if hp <= 0:
		is_dead = true
		emit_signal("destroyed", self)

func get_hp():
	return hp


### FUNCTIONS

func destroy(free_self: bool = true):
	Global.spawn_object_at_position(DESTROY_EFFECT, global_position)
	SfxPlayer.play_sfx(DESTROY_SOUND)
	if free_self:
		queue_free()

func receive_damage(received_damage):
	print("Structure " + name + " got " + str(received_damage) + " damage!")
	if !invincible:
		self.hp -= received_damage
	
#	effectPlayer.stop()
#	effectPlayer.play("hit")
	
	SfxPlayer.play_sfx(DAMAGE_SOUND, get_tree().current_scene, Vector2(0.9, 1.2))

func _on_Hurtbox_area_entered(hitbox):
	if hitbox.is_in_group("Hitbox"):
		receive_damage(hitbox.damage)
		
		if hitbox.is_in_group("Projectile"):
			hitbox.destroy()
		
		SfxPlayer.play_sfx(DAMAGE_SOUND, get_tree().current_scene, Vector2(0.8, 1.1))
	#	spawn_effect(EFFECT_HIT)



func _on_StructureBase_destroyed(object):
	SfxPlayer.play_sfx(DESTROY_SOUND)
	queue_free()


func _on_CatchFireArea_area_entered(area):
	if area.get_path() != firePosition.remote_path and area.is_in_group("Fire"):
		statusEffectHandler.catch_fire()
		
		if firePosition.remote_path == "":
			var fire_object: Node2D = Global.FIRE_SCENE.instance()
			fire_object.extinguishable = statusEffectHandler.extinguishable
			get_tree().current_scene.add_child(fire_object)
			firePosition.remote_path = fire_object.get_path()


func _on_StatusEffectHandler_on_fire_changed(on_fire):
	if on_fire:
		modulate = Color.red
	else:
		modulate = Color.white
		
		if firePosition.remote_path != "":
			var fire_object = get_tree().current_scene.get_node(firePosition.remote_path)
			if fire_object:
				fire_object.queue_free()
				firePosition.remote_path = ""
		
		$CatchFireArea/CollisionShape2D.set_deferred("disabled", true)
		$CatchFireArea/CollisionShape2D.set_deferred("disabled", false)


func _on_StatusEffectHandler_received_fire_damage(fire_damage):
	self.hp -= fire_damage
