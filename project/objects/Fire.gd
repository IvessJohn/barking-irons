extends Area2D

var attached_to: String = ""

export(bool) var extinguishable: bool = true


func _ready():
	if extinguishable:
		$ExtinguishTimer.start()

func _on_ExtinguishTimer_timeout():
	if extinguishable:
		queue_free()
