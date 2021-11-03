extends Camera2D

var current_intensivity: int = 0

onready var camTween = $Tween

func start_new_shake(new_intensivity: int, shake_length: float = 0.2, delay: float = 0.05):
	if new_intensivity >= current_intensivity:
		camTween.stop_all()
		current_intensivity = new_intensivity #* GlobalSettings.CAMERA_SHAKE_MODIFIER
		camTween.interpolate_method(self, "shake_in_range", current_intensivity,
				0, shake_length, Tween.TRANS_SINE, Tween.EASE_IN, delay)
		camTween.start()

func shake_in_range(shake_range):
	offset = Vector2(rand_range(-shake_range, shake_range), rand_range(-shake_range, shake_range))

func _on_Tween_tween_all_completed():
	current_intensivity = 0

#func _on_Tween_tween_completed(object, key):
#	current_intensivity = 0
