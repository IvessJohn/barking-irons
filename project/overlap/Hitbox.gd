extends Area2D
 
export(int) var damage: int = 10 setget , get_damage
export(bool) var reference_parent_damage: bool = false

var hit_owner = null
 
 
func get_damage() -> int:
	if reference_parent_damage:
		return get_parent().damage
	return damage
