extends Area2D


func set_collisionShape_disabled(disabled: bool):
	$CollisionShape2D.set_deferred("disabled", disabled)
