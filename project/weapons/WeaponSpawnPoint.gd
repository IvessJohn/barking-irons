extends Position2D

export(Array) var WEAPONS: Array = [
	preload("res://project/objects/pickables/RevolverItem.tscn"),
	preload("res://project/objects/pickables/TorchItem.tscn")
]
export(int) var capacity: int = 9999
export(bool) var respawning: bool = true
export(float) var respawn_time: float = 5.0

onready var spawnTimer = $SpawnTimer
var weapon_object: Node2D = null


func respawn_weapon():
	if WEAPONS.size() > 0:
		capacity -= 1
		
		var weaponItem = WEAPONS.front()
		WEAPONS.shuffle()
		
		weapon_object = Global.spawn_object_at_position(weaponItem, $WeaponPosition.global_position, $WeaponPosition)
		weapon_object.connect("tree_exited", self, "weapon_object_tree_exited")
		print(name + " spawned a weapon: " + weapon_object.name)

func weapon_object_tree_exited():
	if weapon_object.is_connected("tree_exited", self, "weapon_object_tree_exited"):
		weapon_object.disconnect("tree_exited", self, "weapon_object_tree_exited")
	
	if capacity > 0:
		spawnTimer.start()
