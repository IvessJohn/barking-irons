extends Position2D

export(Array) var WEAPONS: Array = [
	preload("res://project/objects/pickables/RevolverItem.tscn"),
	preload("res://project/objects/pickables/TorchItem.tscn")
]
export(int) var capacity: int = 9999
export(bool) var respawning: bool = true
var is_currently_respawning: bool = false
export(float) var respawn_time: float = 5.0

onready var spawnTimer = $SpawnTimer
var weapon_object: Node2D = null


func _ready():
	spawnTimer.wait_time = respawn_time
	if respawning:
		spawnTimer.start()

func respawn_weapon():
	if !is_currently_respawning and WEAPONS.size() > 0:
		is_currently_respawning = true
		spawnTimer.stop()
		capacity -= 1
		
		var weaponItem = WEAPONS.front()
		WEAPONS.shuffle()
		
		weapon_object = Global.spawn_object_at_position(weaponItem, $WeaponPosition.global_position, $WeaponPosition)
		weapon_object.connect("removed", self, "weapon_object_removed")
		print(name + " spawned a weapon: " + weapon_object.name)
		is_currently_respawning = false
		
		if capacity < 1:
			disappear()

func weapon_object_removed():
	if weapon_object.is_connected("removed", self, "weapon_object_removed"):
		weapon_object.disconnect("removed", self, "weapon_object_removed")
	
	if get_tree().get_nodes_in_group("WeaponItem").size() == 0:
		var other_weaponSpawners: Array = get_tree().get_nodes_in_group("WeaponSpawner")
		other_weaponSpawners.erase(self)
		if other_weaponSpawners.size() > 0:
			other_weaponSpawners.shuffle()
			other_weaponSpawners[0].respawn_weapon()
	
	if capacity > 0:
		spawnTimer.start()

func disappear():
	queue_free()
