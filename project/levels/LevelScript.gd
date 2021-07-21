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

enum RANDOM_EVENTS {
	RUNNING_HORSE,
	EAGLE_SCREAMING
}

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
	player.revolver.connect("shot", drumUI, "shot")
	player.connect("picked_revolver", drumUI, "show")
	player.revolver.connect("magazine_emptied", drumUI, "hide")


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
