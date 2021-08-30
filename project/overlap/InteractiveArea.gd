extends Area2D
class_name InteractiveArea

signal interacted(interacting_object, interacted_area)


func interact(interacting_object):
	emit_signal("interacted", interacting_object, self)
