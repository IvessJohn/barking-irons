extends Node2D

var LEVEL_ARRAYS_DICT: Dictionary = {
	Global.GAME_MODES.CASUAL_DUEL: [
		"res://project/levels/small_maps/SmallDesert.tscn",
		"res://project/levels/small_maps/SmallTown.tscn",
		"res://project/levels/small_maps/ATonOfExplosives.tscn"
	],
	Global.GAME_MODES.ARENA: [
		
	]
}

enum LEVEL_TYPES {
	LEVEL_DUEL,		# 1v1 battle
	ARCADE_ARENA	# Survival mode
}
export(Global.GAME_MODES) var game_mode: int = Global.GAME_MODES.CASUAL_DUEL
var game_finished: bool = false

export(PackedScene) var ENEMY_SCENE: PackedScene = null
export(bool) var enemies_disabled: bool = false

export(Vector2) var WIND_DIRECTION: Vector2 = Vector2.RIGHT
var aim_deviation_sandstorm: int setget , get_aim_deviation_sandstorm
enum SANDSTORM_TYPES {
	NONE,
	WEAK,
	STRONG
}
export(SANDSTORM_TYPES) var current_sandstorm: int = SANDSTORM_TYPES.NONE

export(PackedScene) var TUMBLEWEED: PackedScene = preload("res://project/objects/Tumbleweed.tscn")

export(bool) var show_additional_vfx: bool = true	# Sandstorm

var player_shot_himself: bool = false

onready var player = $Player
onready var battleUI = $UI/BattleUI
onready var messageShower = $UI/MessageShower
onready var finalScreen = $UI/FinalScreen
onready var enemySpawnPositionsArr = $EnemySpawnPositions.get_children()
onready var randomEventGenerator = $RandomEventGenerator
onready var aceTimeController = $AceTimeController


func _ready():
	randomize()
	yield(get_tree(), "idle_frame")
	randomEventGenerator.is_generating = false
	connect_ui_elements()
	SoundtrackPlayer.play_soundtrack(SoundtrackPlayer.THEMES.BATTLE)
	SoundtrackPlayer.streamPlayer.volume_db = 0
	
	# This piece of code became obsolete since you can just manually disconnect
	#  the signals rather than make everything based on code
#	var all_weapons: Array = get_tree().get_nodes_in_group("WeaponItem")
#	if all_weapons.size() == 1 and all_weapons[0].is_in_group("RevolverItem"):
#		if get_tree().get_nodes_in_group("WeaponSpawner").size() == 0:
#			all_weapons[0].connect("_on_RevolverItem_destroyed")
#			all_weapons[0].connect("_on_RevolverItem_picked")
	
#	if show_additional_vfx:
#		var sandstormHandler = $SandstormHandler
#		sandstormHandler.rotation_degrees = rand_range(0, 360)
#		if randf() < chance_weakSandstorm:
#			sandstormHandler.show()
#			sandstormHandler.get_child(0).show()
#			sandstormHandler.get_child(0).emitting = true
	
	Global.current_game_mode = game_mode
	match (game_mode):
		Global.GAME_MODES.CASUAL_DUEL:
			spawn_enemy(enemySpawnPositionsArr[0].global_position, 1 * 0.01)
		Global.GAME_MODES.ARENA:
			$EnemySpawnTimer.start()
	
	randomEventGenerator.is_generating = true

func _input(event):
	if Input.is_action_just_pressed("ability_acetime"):
		aceTimeController.request_acetime_change()

func connect_ui_elements():
	# Revolver drum
	var drumUI = $UI/BattleUI.revolverDrum
	player.weapons[player.ARMED_STATES.REVOLVER].connect("shot", drumUI, "shot")
	player.connect("picked_revolver", drumUI, "show")
	player.weapons[player.ARMED_STATES.REVOLVER].connect("magazine_emptied", drumUI, "hide")


func _on_RevolverItem_picked(picker_object: Node2D):
	if Global.current_game_mode == Global.GAME_MODES.CASUAL_DUEL:
		var picker_name: String = ""
		if picker_object.is_in_group("Player"):
			picker_name = "Player"
		elif picker_object.is_in_group("Enemy"):
			picker_name = "Enemy"
		messageShower.show_message("ROD CLAIMED", "by " + picker_name)

func game_end():
	game_finished = true
	
	$EnemySpawnTimer.paused = true
	
	var stopped_objects = []
	stopped_objects.append_array(get_tree().get_nodes_in_group("Cowboy"))
#	stopped_objects.append_array(get_tree().get_nodes_in_group("Entity"))
#	stopped_objects.append_array(get_tree().get_nodes_in_group("Tumbleweed"))
	
	for o in stopped_objects:
		o.set_deferred("can_move", false)
		o.set_deferred("active", false)
#	randomEventGenerator.stop_generating_events()

func _on_Player_died(_player):
	if !game_finished:
		player.can_move = false
		player.hide()
		
		var enemies = get_tree().get_nodes_in_group("Enemy")
		for e in enemies:
			e.set_deferred("player", null)
	#		e.set_deferred("FOLLOWS_PATH", false)
			e.set_deferred("can_move", false)
		
		if !player_shot_himself:
			finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.DEFEAT, "You were killed.")
		else:
			finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.DEFEAT, "You have just killed yourself. Genius.")
		game_end()


func _on_CheatBorders_body_entered(body):
	if !game_finished:
		var message: String = ""
		if body.is_in_group("Player"):
			message = "You have fled from the battlefield - not a bug, it's a feature."
			finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, message)
			game_end()
		elif game_mode != Global.GAME_MODES.ARENA:
			if body.is_in_group("Enemy") and body.is_spawned:
				message = "You have literally pushed him out!"
				finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, message)
				game_end()

func _on_RevolverItem_destroyed():
	match (game_mode):
		Global.GAME_MODES.CASUAL_DUEL:
			finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "Gun broken. No gun - no fight.")
			game_end()

func _on_EnemyBase_died(enemy_object: KinematicBody2D):
	if !game_finished:
		match (game_mode):
			Global.GAME_MODES.CASUAL_DUEL:
				if player != null and !player.moved_while_paused:
					finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "Fair win.")
				else:
					finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "You didn't control time, did you?")
				game_end()
			Global.GAME_MODES.ARENA:
				$ArenaController.enemy_died(enemy_object)
		
		enemy_object.disconnect("died", self, "_on_EnemyBase_died")


func start_new_level():
	randomize()
	var found_next_level = false
	if LEVEL_ARRAYS_DICT[game_mode].size() > 0:
		var next_level: String = LEVEL_ARRAYS_DICT[game_mode][randi() % LEVEL_ARRAYS_DICT[game_mode].size()]
		if next_level != "":
# warning-ignore:return_value_discarded
			get_tree().change_scene(next_level)
			found_next_level = true
	if !found_next_level:
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()


func _on_FinalScreen_request_new_level():
	start_new_level()

func spawn_enemy(pos: Vector2 = enemySpawnPositionsArr[randi() % enemySpawnPositionsArr.size()].global_position, delay: float = 0):
	if !enemies_disabled and ENEMY_SCENE:
		if delay > 0:
			yield(get_tree().create_timer(delay), "timeout")
		var enemy = ENEMY_SCENE.instance()
		
		enemy.connect("died", self, "_on_EnemyBase_died")
		
		add_child(enemy)
		enemy.global_position = pos
		enemy.is_spawned = true


func _on_EnemySpawnTimer_timeout():
	spawn_enemy()

func return_player():
	return player

func get_aim_deviation_sandstorm() -> int:
	var aim_deviation: int = 0
	
	return aim_deviation

func _on_RandomEventGenerator_event_happened(event_num):
	print("event happened: " + str(event_num))
	yield(get_tree(), "idle_frame")
	match event_num:
#		"TUMBLEWEED":
		randomEventGenerator.EVENTS.TUMBLEWEED:
			var tumbleweed = TUMBLEWEED.instance()
			var spawn_position = Vector2(0, rand_range(20,260))
			
			get_tree().current_scene.add_child(tumbleweed)
			if WIND_DIRECTION == Vector2.LEFT:
				spawn_position = Vector2(270, rand_range(20,260))
				tumbleweed.sprite.scale.x = -1
				tumbleweed.DIRECTION = WIND_DIRECTION
			
			tumbleweed.global_position = spawn_position
		
#		"EAGLE_SCREAMING":
		randomEventGenerator.EVENTS.EAGLE_SCREAMING:
			var eagle = randomEventGenerator.EAGLE.instance()
			var spawn_position = Vector2(-10, rand_range(40,260))
			
			get_tree().current_scene.add_child(eagle)
			var left_facing: bool = (randi() % 2 == 0)
			if left_facing:
				spawn_position = Vector2(530, rand_range(40,260))
				eagle.sprite.scale.x = -1
			
			eagle.global_position = spawn_position
		
#		"HORSE_RUNNING":
		randomEventGenerator.EVENTS.HORSE_RUNNING:
			var horse = randomEventGenerator.HORSE.instance()
			var spawn_position = Vector2(0, rand_range(20,260))
			
			get_tree().current_scene.add_child(horse)
			var left_facing: bool = (randi() % 2 == 0)
			if left_facing:
				spawn_position = Vector2(530, rand_range(20,260))
				horse.sprite.scale.x = -1
				horse.RUNNING_DIR = Vector2.LEFT
			
			horse.global_position = spawn_position
#		"SANDSTORM_WEAK":
		randomEventGenerator.EVENTS.SANDSTORM_WEAK:
			messageShower.show_message("Weak sandstorm started")
			$SandstormHandler.start_sandstorm($SandstormHandler.SANDSTORMS.WEAK)
			# Remove the possibility of respawning the sandstorm while it's still active
			randomEventGenerator.EVENTS_CHANCES[event_num] = 0
#		"SANDSTORM_STRONG":
		randomEventGenerator.EVENTS.SANDSTORM_STRONG:
			messageShower.show_message("Strong sandstorm started!")
			
			var affected_objects = []
			affected_objects.append_array(get_tree().get_nodes_in_group("Entity"))
		#	stopped_objects.append_array(get_tree().get_nodes_in_group("Tumbleweed"))
			for o in affected_objects:
				o.set_deferred("current_wind_dir", WIND_DIRECTION)


func _on_BordersTurnOnTimer_timeout():
	$CheatBorders.monitoring = true


func _on_AceTimeController_acetime_active_changed(_new_acetime):
	pass # Replace with function body.
