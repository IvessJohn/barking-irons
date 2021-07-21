extends KinematicBody2D


signal hp_changed(new_hp)
signal got_hit(damage)
signal hp_max_changed(new_hp_max)
signal died(object)
signal picked_revolver


export(int) var hp_max: int = 100 setget set_hp_max
export(int) var hp: int = 100 setget set_hp, get_hp
export(bool) var invincible: bool = false
var is_dead: bool = false

export(PackedScene) var HIT_EFFECT: PackedScene = null
export(PackedScene) var DEATH_EFFECT: PackedScene = null

export(AudioStream) var HIT_SOUND: AudioStream = null
export(AudioStream) var DEATH_SOUND: AudioStream = null

export(bool) var can_move: bool = true
export(int) var SPEED: int = 40
export(float) var SPEED_MODIFIER: float = 1.0
var velocity: Vector2 = Vector2.ZERO

export(bool) var receives_knockback: bool = true
export(float) var knockback_modifier: float = 17
var current_knockback: Vector2 = Vector2.ZERO

enum ARMED_STATES {
	UNARMED,
	REVOLVER
}
export(ARMED_STATES) var current_armed_state = ARMED_STATES.UNARMED

export(PackedScene) var HIT_SCENE: PackedScene = null
export(int) var HIT_DAMAGE: int = 10

export(float) var RECOIL_HIT: float = 0.15
export(float) var RECOIL_SHOOT: float = 0.15

onready var sprite = $Sprite
onready var animPlayer = $AnimationPlayer
onready var collShape = $CollisionShape2D
onready var hurtbox = $Hurtbox
onready var revolver = $RevolverBase
onready var effectPlayer = $EffectPlayer
onready var projSpawn = $ProjSpawnPivot/ProjectileSpawn


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
		emit_signal("died", self)

func get_hp():
	return hp

func apply_and_decrease_knockback():
	velocity += current_knockback
	current_knockback = lerp(current_knockback, Vector2.ZERO, 0.1)

func move():
	if can_move:
		velocity = move_and_slide(velocity)

func receive_damage(received_damage):
	print(name + " got " + str(received_damage) + " damage!")
	if !invincible:
		self.hp -= received_damage
	
#	effectPlayer.stop()
#	effectPlayer.play("hit")
	if get_tree().has_group("PauseController"):
		var pcontroller = get_tree().get_nodes_in_group("PauseController")[0]
		pcontroller.trigger_damage_pause()
	
	SfxPlayer.play_sfx(HIT_SOUND, get_tree().current_scene, Vector2(0.9, 1.2))

func die(free_self: bool = true):
	spawn_object_at_position(DEATH_EFFECT)
	SfxPlayer.play_sfx(DEATH_SOUND)
	if free_self:
		queue_free()

func spawn_object_at_position(object_scene: PackedScene, object_pos: Vector2 = global_position):
	var object: Node2D = null
	if object_scene:
		object = object_scene.instance()
		get_tree().current_scene.add_child(object)
		object.global_position = object_pos
	return object

func hit(hit_dir: Vector2):
	if HIT_SCENE:
		var hit_object = spawn_object_at_position(HIT_SCENE, projSpawn.global_position)
		hit_object.rotation = hit_dir.angle()
		hit_object.damage = HIT_DAMAGE
		hit_object.hit_owner = self

func attack_in_direction(attack_direction: Vector2, melee_forced: bool = false):
	if $AttackTimer.is_stopped():
		if melee_forced:
			hit(attack_direction)
			$AttackTimer.start(RECOIL_HIT)
		else:
			revolver.shoot_in_direction(attack_direction, projSpawn.global_position)
			$AttackTimer.start(RECOIL_SHOOT)

func receive_knockback(damage_source_pos: Vector2, received_damage: int):
	if receives_knockback:
		var knockback_direction = damage_source_pos.direction_to(self.global_position)
		var knockback_strength = received_damage * knockback_modifier
		current_knockback = knockback_direction * knockback_strength
		
#		global_position += knockback


func _on_Hurtbox_area_entered(hitbox):
	if hitbox.is_in_group("Hitbox"):
		receive_damage(hitbox.damage)
		receive_knockback(hitbox.global_position, hitbox.damage)
		
		if hitbox.is_in_group("Projectile"):
			hitbox.destroy()
		
		SfxPlayer.play_sfx(HIT_SOUND, get_tree().current_scene, Vector2(0.8, 1.1))
	#	spawn_effect(EFFECT_HIT)


func _on_PickupArea_area_entered(item):
	if item.is_in_group("Pickable"):
		match item.PICKABLE_TYPE:
			"revolver":
				current_armed_state = ARMED_STATES.REVOLVER
				$ProjSpawnPivot/ProjectileSpawn/RevolverSprite.show()
				
				revolver.bullets = revolver.BULLETS_DEFAULT
				emit_signal("picked_revolver")
		
		item.pick_up(self)


func _on_RevolverBase_magazine_emptied():
	current_armed_state = ARMED_STATES.UNARMED
	$ProjSpawnPivot/ProjectileSpawn/RevolverSprite.hide()


func _on_EntityBase_died(_entity):
	die()

