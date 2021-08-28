extends "res://project/objects/structures/StructureBase.gd"


onready var flipTween = $FlipTween


func flip():
	hurtbox.set_collisionShape_disabled(false)
	
	var target_position = global_position
	
	flipTween.interpolate_property(self)
