extends Node2D

const RIGHT = Vector2.RIGHT
export(int) var SPEED: int = 40

onready var sprite = $Sprite
onready var statusEffectHandler = $StatusEffectHandler
onready var firePosition = $FirePosition


func _physics_process(delta):
	var movement = RIGHT.rotated(rotation) * SPEED * delta
	global_position += movement
	sprite.rotation_degrees += SPEED * 2 * delta

func destroy():
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
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
