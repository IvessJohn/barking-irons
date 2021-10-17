tool
extends Node

signal game_mode_changed(new_game_mode)

export(bool) var just_launched: bool = true

enum GAME_MODES {
	MENU,
	CASUAL_DUEL,
	ARENA,
	LAN_MULTIPLAYER
}
var current_game_mode = GAME_MODES.MENU setget set_game_mode

var LEVEL_ARRAYS_DICT: Dictionary = {
	GAME_MODES.CASUAL_DUEL: [
		"res://project/levels/small_maps/SmallDesert.tscn",
		"res://project/levels/small_maps/SmallTown.tscn",
		"res://project/levels/small_maps/ATonOfExplosives.tscn"
	],
	GAME_MODES.ARENA: [
		
	]
}

export(PackedScene) var FIRE_SCENE: PackedScene = preload("res://project/objects/Fire.tscn")


func set_game_mode(value):
	if current_game_mode != value:
		current_game_mode = value
		emit_signal("game_mode_changed", current_game_mode)

func spawn_object_at_position(object_scene: PackedScene, object_pos: Vector2, parent: Node = get_tree().current_scene):
	var object: Node2D = null
	if object_scene:
		object = object_scene.instance()
		parent.add_child(object)
		object.global_position = object_pos
	return object
