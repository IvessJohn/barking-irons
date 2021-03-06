extends "res://project/entities/EntityBase.gd"

var randomly_choosing_direction: bool = false
export(Vector2) var RUNNING_DIR: Vector2 = Vector2.RIGHT

export(AudioStream) var NEIGH_SOUND: AudioStream = null

export(float) var change_skin_chance: float = 0.3


func _ready():
	if randomly_choosing_direction and (randi() % 2 == 0):
		RUNNING_DIR = Vector2.LEFT
		sprite.scale.x = -1
	
	if randf() < change_skin_chance:
		var texture_region = sprite.region_rect
		texture_region.position.x += (randi() % 3) * 16
		sprite.region_rect = texture_region

func _physics_process(_delta):
	velocity = RUNNING_DIR * SPEED
	move()

func _on_VisibilityNotifier2D_screen_exited():
	if $AllowFreeTimer.is_stopped():
#		queue_free()
		pass


func _on_VisibilityNotifier2D_screen_entered():
	SfxPlayer.play_sfx(NEIGH_SOUND, get_tree().current_scene, Vector2(0.9, 1.1))
