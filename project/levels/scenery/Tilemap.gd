extends TileMap

export(bool) var replace_tiles_with_objects: bool = false

enum {
	BUILDINGS = 9,
	CACTI = 14,
	EXPLOSIVES = 15,
	BONES = 10,
	DECOR_BUILDINGS = 21,	#
	TOMBSTONES = 16,
	BARRELS = 20,	# Barrels
	SIGNPOST = 19	# Wooden signpost
}

var OBJECTS_DICT: Dictionary = {
	BUILDINGS: 
		["res://project/objects/structures/Building.tscn"],
	CACTI: 
		["res://project/objects/structures/Cacti.tscn"],
	EXPLOSIVES: 
		["res://project/objects/structures/ExplosiveBarrel.tscn"],
	BONES: 
		["res://project/objects/structures/Bones.tscn"],
	DECOR_BUILDINGS: 
		["res://project/objects/structures/DecorBuilding.tscn"],
	TOMBSTONES: 
		["res://project/objects/structures/Tombstone.tscn"],
	BARRELS: 
		["res://project/objects/structures/Barrel.tscn"],
	SIGNPOST: 
		["res://project/objects/structures/Signpost.tscn"]
}


func _ready():
	if replace_tiles_with_objects:
		var tiles = get_used_cells()
		
		for cell_pos in tiles:
			var tile_id = get_cell(cell_pos.x, cell_pos.y)
			if OBJECTS_DICT.has(tile_id):
				var scene: PackedScene = null
				var scene_siblings_amount: int = OBJECTS_DICT[tile_id].size()
				if scene_siblings_amount > 0:
					scene = OBJECTS_DICT[tile_id][randi() % scene_siblings_amount]
				
				if scene != null:
					# Get the local position of the tile
					var world_pos = map_to_world(cell_pos)
					
					# Remove the tile
					set_cell(cell_pos.x, cell_pos.y, 0)
					
					# Place a corresponding object here
					Global.spawn_object_at_position(scene, world_pos)
			continue


