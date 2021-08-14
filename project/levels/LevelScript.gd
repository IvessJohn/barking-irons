extends Node2D

export(Array) var LEVELS_ARRAY: Array = [
	"res://project/levels/Level1.tscn",
	"res://project/levels/Level2.tscn",
	"res://project/levels/Level3.tscn"
]

enum LEVEL_TYPES {
	LEVEL_DUEL,		# 1v1 battle
	ARCADE_ARENA	# Every kill or gun pickup spawns a new enemy
}
export(LEVEL_TYPES) var level_type: int = LEVEL_TYPES.LEVEL_DUEL

export(PackedScene) var ENEMY_SCENE: PackedScene = null
export(bool) var enemies_disabled: bool = false

<<<<<<< HEAD
export(Vector2) var WIND_DIRECTION: Vector2 = Vector2.RIGHT
var aim_deviation_sandstorm: int setget , get_aim_deviation_sandstorm
enum SANDSTORM_TYPES {
	NONE,
	WEAK,
	STRONG
}
export(SANDSTORM_TYPES) var current_sandstorm: int = SANDSTORM_TYPES.NONE

export(PackedScene) var TUMBLEWEED: PackedScene = preload("res://project/objects/Tumbleweed.tscn")
export(PackedScene) var HORSE: PackedScene = preload("res://project/entities/other entities/RunningHorse.tscn")
=======
enum RANDOM_EVENTS {
	RUNNING_HORSE,
	EAGLE_SCREAMING
}
>>>>>>> parent of 62e6fef (Random Events + Status Effect systems)

export(bool) var show_additional_vfx: bool = true	# Sandstorm
export(float, 0.0, 1.0) var chance_weakSandstorm = 0.3
export(float, 0.0, 1.0) var chance_strongSandstorm = 0.1

var player_shot_himself: bool = false

onready var player = $Player
onready var battleUI = $UI/BattleUI
onready var messageShower = $UI/MessageShower
onready var finalScreen = $UI/FinalScreen
onready var enemySpawnPositionsArr = $EnemySpawnPositions.get_children()
onready var randomEventGenerator = $RandomEventGenerator


func _ready():
	randomize()
	connect_ui_elements()
	SoundtrackPlayer.play_soundtrack(SoundtrackPlayer.THEMES.BATTLE)
	SoundtrackPlayer.streamPlayer.volume_db = 0
	
	if show_additional_vfx:
		var sandstormHandler = $SandstormHandler
		sandstormHandler.rotation_degrees = rand_range(0, 360)
		if randf() < chance_weakSandstorm:
			sandstormHandler.show()
			sandstormHandler.get_child(0).show()
			sandstormHandler.get_child(0).emitting = true
	
	match (level_type):
		LEVEL_TYPES.LEVEL_DUEL:
			spawn_enemy(enemySpawnPositionsArr[0].global_position)
		LEVEL_TYPES.ARCADE_ARENA:
			$EnemySpawnTimer.start()

func connect_ui_elements():
	# Revolver drum
	var drumUI = $UI/BattleUI.revolverDrum
	player.weapons[player.ARMED_STATES.REVOLVER].connect("shot", drumUI, "shot")
	player.connect("picked_revolver", drumUI, "show")
	player.weapons[player.ARMED_STATES.REVOLVER].connect("magazine_emptied", drumUI, "hide")


func _on_RevolverItem_picked(picker_object: Node2D):
#	match (level_type):
#		LEVEL_TYPES.LEVEL_DUEL:
	var picker_name: String = ""
	if picker_object.is_in_group("Player"):
		picker_name = "Player"
	elif picker_object.is_in_group("Enemy"):
		picker_name = "Enemy"
	messageShower.show_message("ROD CLAIMED", "by " + picker_name)

func game_end():
	var entities = get_tree().get_nodes_in_group("Entity")
	for e in entities:
		e.set_deferred("can_move", false)

#func _on_Player_shot_himself():
#	finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.DEFEAT, "You have just shot yourself. Genius.")
#	game_end()

func _on_Player_died(_player):
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
	if body.is_in_group("Player"):
		finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "You have fled from the battlefield - not a bug, it's a feature.")
		game_end()
	elif body.is_in_group("Enemy"):
		finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "You have literally pushed him out!")
		game_end()


func _on_RevolverItem_destroyed():
	match (level_type):
		LEVEL_TYPES.LEVEL_DUEL:
			finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "Gun broken. No gun - no fight.")
			game_end()


func _on_EnemyBase_died(enemy_object: KinematicBody2D):
	match (level_type):
		LEVEL_TYPES.LEVEL_DUEL:
			if player != null and !player.moved_while_paused:
				finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "Fair win.")
			else:
				finalScreen.show_screen(finalScreen.FINAL_POSSIBILITY.VICTORY, "You didn't control time, did you?")
			game_end()
		LEVEL_TYPES.ARCADE_ARENA:
			$EnemySpawnTimer.start()
	
	enemy_object.disconnect("died", self, "_on_EnemyBase_died")

func start_new_level():
	randomize()
	var found_next_level = false
	if LEVELS_ARRAY.size() > 0:
		var next_level: String = LEVELS_ARRAY[randi() % LEVELS_ARRAY.size()]
		if next_level != "":
# warning-ignore:return_value_discarded
			get_tree().change_scene(next_level)
			found_next_level = true
	if !found_next_level:
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()


func _on_FinalScreen_request_new_level():
	start_new_level()

func spawn_enemy(pos: Vector2 = enemySpawnPositionsArr[randi() % enemySpawnPositionsArr.size()].global_position):
	if !enemies_disabled and ENEMY_SCENE:
		var enemy = ENEMY_SCENE.instance()
		
		enemy.connect("died", self, "_on_EnemyBase_died")
		
		add_child(enemy)
		enemy.global_position = pos


func _on_EnemySpawnTimer_timeout():
	spawn_enemy()

func return_player():
	return player

func return_revolverItem():
	return get_tree().get_nodes_in_group("RevolverItem")[0]
<<<<<<< HEAD

func get_aim_deviation_sandstorm() -> int:
	var aim_deviation: int = 0
	
	return aim_deviation

func _on_RandomEventGenerator_event_happened(event_num):
	print("event happdened: " + str(event_num))
	yield(get_tree(), "idle_frame")
	match event_num:
		"TUMBLEWEED":
			var tumbleweed = TUMBLEWEED.instance()
			var spawn_position = Vector2(0, rand_range(20,260))
			
			get_tree().current_scene.add_child(tumbleweed)
			if WIND_DIRECTION == Vector2.LEFT:
				spawn_position = Vector2(270, rand_range(20,260))
				tumbleweed.sprite.scale.x = -1
				tumbleweed.DIRECTION = WIND_DIRECTION
			
			tumbleweed.global_position = spawn_position
		
		"EAGLE_SCREAMING":
			SfxPlayer.play_sfx(randomEventGenerator.EAGLE_SFX)
		
		"HORSE_RUNNING":
			var horse = randomEventGenerator.HORSE.instance()
			var spawn_position = Vector2(0, rand_range(20,260))
			
			get_tree().current_scene.add_child(horse)
			var left_facing: bool = (randi() % 2 == 0)
			if left_facing:
				spawn_position = Vector2(270, rand_range(20,260))
				horse.sprite.scale.x = -1
				horse.RUNNING_DIR = Vector2.LEFT
			
			horse.global_position = spawn_position
		"SANDSTORM_WEAK":
			messageShower.show_message("Weak sandstorm started")
		"SANDSTORM_STRONG":
			messageShower.show_message("Strong sandstorm started!")
			
			var affected_objects = []
			affected_objects.append_array(get_tree().get_nodes_in_group("Entity"))
		#	stopped_objects.append_array(get_tree().get_nodes_in_group("Tumbleweed"))
			for o in affected_objects:
				o.set_deferred("current_wind_dir", WIND_DIRECTION)


func _on_BordersTurnOnTimer_timeout():
	$CheatBorders.monitoring = true
=======
>>>>>>> parent of 62e6fef (Random Events + Status Effect systems)
