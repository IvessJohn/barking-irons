extends Position2D

export(Array) var WEAPONS: Array = [
	preload("res://project/weapons/drop resources/Revolver.tres"),
	preload("res://project/weapons/drop resources/Torch.tres")
]
export(bool) var respawning: bool = true
export(float) var respawn_time: float = 5.0

onready var timer = $Timer


func respawn_weapon():
	pass
