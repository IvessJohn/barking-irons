extends Node

var claimed_weaponItems: Dictionary = {}

func count_unclaimed_weapons() -> int:
	var unclaimed_weapons: int = 0
	
	var weapons_on_the_map = get_tree().get_nodes_in_group("WeaponItem")
	for item in weapons_on_the_map:
		if not item in claimed_weaponItems.keys():
			unclaimed_weapons += 1
	
	return unclaimed_weapons
