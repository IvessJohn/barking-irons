extends Area2D

var attached_to: String = ""

export(bool) var extinguishable: bool = true setget set_extinguishable

onready var extinguishTimer = $ExtinguishTimer


func _ready():
	yield(get_tree(), "idle_frame")
	self.extinguishable = extinguishable

func set_extinguishable(value: bool):
	extinguishable = value
	if extinguishable and $ExtinguishTimer.is_stopped():
			$ExtinguishTimer.start()

func _on_ExtinguishTimer_timeout():
	queue_free()
