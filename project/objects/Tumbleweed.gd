extends Node2D

const RIGHT = Vector2.RIGHT
export(int) var SPEED: int = 40

onready var sprite = $Sprite


func _physics_process(delta):
	var movement = RIGHT.rotated(rotation) * SPEED * delta
	global_position += movement
	sprite.rotation_degrees += SPEED * 2 * delta

func destroy():
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Hurtbox_area_entered(area):
	destroy()
