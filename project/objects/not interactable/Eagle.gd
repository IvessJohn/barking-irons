extends Node2D

export(int) var SPEED: int = 90


onready var sprite = $Sprite


func _physics_process(delta):
	var movement = Vector2.RIGHT * sign(sprite.scale.x) * SPEED * delta
	global_position += movement

func _on_VisibilityNotifier2D_screen_exited():
	if $VisibilityNotifier2D/AllowFreeTimer.is_stopped():
		queue_free()
