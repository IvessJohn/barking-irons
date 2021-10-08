extends "res://project/objects/structures/StructureBase.gd"


var is_sparking: bool = false
export(int) var spark_self_damage: int = 2

export(PackedScene) var EXPLOSION: PackedScene = preload("res://project/weapons/explosion/Explosion.tscn")


func _ready():
	$SparkAutoDamageTimer.stop()
	$SparkParticles.hide()

func _on_ExplosionBarrel_destroyed(_self):
	var explosion_position = global_position
	destroy()
	Global.call_deferred("spawn_object_at_position", EXPLOSION, explosion_position)

func _on_ExplosiveBarrel_got_hit(damage):
	if !is_sparking:
		is_sparking = true
		$SparkAutoDamageTimer.start()
		$SparkParticles.show()

func _on_SparkAutoDamageTimer_timeout():
	self.hp -= spark_self_damage
