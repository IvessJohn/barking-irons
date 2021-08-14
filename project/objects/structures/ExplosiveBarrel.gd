extends "res://project/objects/structures/StructureBase.gd"


export(PackedScene) var EXPLOSION: PackedScene = preload("res://project/weapons/explosion/Explosion.tscn")


func _on_ExplosionBarrel_destroyed(_self):
	var explosion_position = global_position
	destroy()
	Global.call_deferred("spawn_object_at_position", EXPLOSION, explosion_position)
