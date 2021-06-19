extends "res://project/overlap/Hitbox.gd"

const RIGHT = Vector2.RIGHT
export(int) var SPEED: int = 200


func _physics_process(delta):
	var movement = RIGHT.rotated(rotation) * SPEED * delta
	global_position += movement

func destroy():
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
