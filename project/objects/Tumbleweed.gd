extends Node2D

export(bool) var can_move = true setget set_can_move
var DIRECTION = Vector2.RIGHT
export(int) var SPEED: int = 40

onready var sprite = $Sprite
onready var statusEffectHandler = $StatusEffectHandler
onready var firePosition = $FirePosition


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


func _on_Hurtbox_area_entered(_area):
	destroy()


func _on_CatchFireArea_area_entered(area):
	if area.get_path() != firePosition.remote_path and area.is_in_group("Fire"):
		statusEffectHandler.catch_fire()
		
		if firePosition.remote_path == "":
			var fire_object: Node2D = Global.FIRE_SCENE.instance()
			fire_object.extinguishable = statusEffectHandler.extinguishable
			get_tree().current_scene.add_child(fire_object)
			firePosition.remote_path = fire_object.get_path()
