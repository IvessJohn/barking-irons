tool
extends Node

signal game_mode_changed(new_game_mode)

enum GAME_MODES {
	MENU,
	CASUAL,
	ARENA,
	LAN_MULTIPLAYER
}
var current_game_mode = GAME_MODES.MENU setget set_game_mode

export(PackedScene) var FIRE_SCENE: PackedScene = preload("res://project/objects/Fire.tscn")


func set_game_mode(value):
	if current_game_mode != value:
		current_game_mode = value
		emit_signal("game_mode_changed", current_game_mode)

func spawn_object_at_position(object_scene: PackedScene, object_pos: Vector2):
	var object: Node2D = null
	if object_scene:
		object = object_scene.instance()
		get_tree().current_scene.add_child(object)
		object.global_position = object_pos
	return object
