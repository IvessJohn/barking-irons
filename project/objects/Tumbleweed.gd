extends Node2D

export(bool) var can_move = true setget set_can_move
var DIRECTION = Vector2.RIGHT
export(int) var SPEED: int = 40

onready var sprite = $Sprite


func set_can_move(value):
	if can_move != value:
		can_move = value
		$AnimationPlayer.playback_active = can_move


func _physics_process(delta):
	if can_move:
		var movement = DIRECTION * SPEED * delta
		global_position += movement
		sprite.rotation_degrees += SPEED * 2 * delta * sign(DIRECTION.x)

func destroy():
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	if $AllowFreeTimer.is_stopped():
		queue_free()


func _on_Hurtbox_area_entered(area):
	destroy()
