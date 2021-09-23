extends AnimationPlayer

export(Texture) var texture_idle: Texture = null
export(Texture) var texture_move: Texture = null
export(Texture) var texture_die: Texture = null
export(Texture) var texture_fall: Texture = null

enum TEXTURE_TYPES {
	IDLE,
	MOVE,
	DIE,
	FALL
}
var cur_texture_type = TEXTURE_TYPES.IDLE

onready var textures_dic: Dictionary = {
	TEXTURE_TYPES.IDLE: texture_idle,
	TEXTURE_TYPES.MOVE: texture_move,
	TEXTURE_TYPES.DIE: texture_die,
	TEXTURE_TYPES.FALL: texture_fall
}


func get_texture_from_type(texture_type: int = cur_texture_type):
	var texture: Texture = null
	
	if texture_type in textures_dic:
		texture = textures_dic[texture_type]
	
	return texture
