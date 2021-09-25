extends TileMap

export(bool) var replace_tiles_with_objects: bool = true

func _ready():
	if replace_tiles_with_objects:
		var tiles = get_used_cells()
