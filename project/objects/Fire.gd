extends Area2D

var attached_to: String = ""

export(bool) var extinguishable: bool = true

onready var extinguishTimer = $ExtinguishTimer


func _ready():
	if extinguishable:
		extinguishTimer.start()

func _on_ExtinguishTimer_timeout():
	if extinguishable:
		queue_free()
