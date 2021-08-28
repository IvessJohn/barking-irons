extends "res://project/objects/structures/StructureBase.gd"


var flipped: bool = false

export(AudioStream) var SFX_FLIP: AudioStream = null

onready var flipTween = $FlipTween


func _physics_process(delta):
	if Input.is_action_just_pressed("action"):
		if !flipped:
			flip()

func flip():
	flipped = true
	hurtbox.set_collisionShape_disabled(false)
	
	var flip_direction = 1 # Right
	
#	var target_position = global_position +
	var target_rot_degrees = 90 * flip_direction
	
	flipTween.interpolate_property(self, "rotation_degrees", rotation_degrees,
			target_rot_degrees, 0.125, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	flipTween.start()
