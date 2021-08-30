extends "res://project/objects/structures/StructureBase.gd"


var flipped: bool = false

export(AudioStream) var SFX_FLIP: AudioStream = null

onready var flipTween = $FlipTween
onready var interactiveArea = $InteractiveArea


func flip(flip_direction: Vector2 = Vector2.RIGHT):
	interactiveArea.queue_free()
	flipped = true
	hurtbox.set_collisionShape_disabled(false)
	
	if flip_direction == Vector2.LEFT:
		scale.x *= -1
#		global_position -= 4
	
#	var target_position = global_position +
	var target_rot_degrees = 90 * sign(flip_direction.x)
	
	flipTween.interpolate_property(self, "rotation_degrees", rotation_degrees,
			target_rot_degrees, 0.125, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	flipTween.start()


func _on_InteractiveArea_interacted(interacting_object: KinematicBody2D, _interacted_area: Area2D):
	var flip_direction = Vector2.RIGHT
	if interacting_object.global_position.x > global_position.x:
		flip_direction = Vector2.LEFT
	
	flip(flip_direction)
