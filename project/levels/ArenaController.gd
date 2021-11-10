extends Node


signal wave_ended
signal wave_started

enum PHASES {
	INTERMISSION,
	BATTLE
}
export(PHASES) var current_phase = PHASES.INTERMISSION #setget current_phase_changed

var ENEMIES: Array = [
	preload("res://project/entities/enemy/EnemyBase.tscn")
]
var enemies_total: int = 0
var enemies_this_wave: int = 0
var enemies_left_to_spawn: int = 0
var enemies_alive: int = 0

var current_player_faction: int = Global.FACTIONS.OUTLAW

var wave_num: int = 0

var enemy_death_positions: Array = []

export(PackedScene) var BADGE: PackedScene = preload("res://project/objects/pickables/collectibles/BadgeItem.tscn")
var badges_picked_this_wave: int = 0
var badges_picked_total: int = 0

export(AudioStream) var SFX_WAVE_START: AudioStream = null
export(AudioStream) var SFX_WAVE_END: AudioStream = null
export(AudioStream) var SFX_PLAYERS_UNITED: AudioStream = null
export(AudioStream) var SFX_GAME_LOST: AudioStream = null


onready var BADGES: Node2D = $Badges


func _ready():
	randomize()
#	SoundtrackPlayer.pause_soundtrack()
	
	self.current_phase = PHASES.INTERMISSION
	SoundtrackPlayer.play_soundtrack(SoundtrackPlayer.THEMES.INTERMISSION)
	$IntermissionTimer.start()

func start_battle():
	print("battle start!")
#	SoundtrackPlayer.pause_soundtrack()
	get_tree().call_group("BadgeItem", "queue_free")
	badges_picked_this_wave = 0
	
	self.current_phase = PHASES.BATTLE
	wave_num += 1
	enemies_this_wave += int(rand_range(0, 3))
	enemies_this_wave = clamp(enemies_this_wave, 3, 15)
	enemies_left_to_spawn = enemies_this_wave
	enemies_total += enemies_this_wave
	
	emit_signal("wave_started")
	
#	enemies_left_to_spawn = levelStats.next_wave_enemies_amount
	$EnemySpawnTimer.start()
#	$UI/BattleUI/HBoxContainer/TimeLeft.hide()
#	$UI/BattleUI/HBoxContainer/EnemiesLeft.show()
#	$UI/BattleUI/HBoxContainer/EnemiesLeft/Number.text = str(enemies_left_to_spawn)
	
	var wave_sound: AudioStreamPlayer = SfxPlayer.play_sfx(SFX_WAVE_START)
	if wave_sound:
		yield(wave_sound, "finished")
	SoundtrackPlayer.play_soundtrack(SoundtrackPlayer.THEMES.BATTLE)

func start_intermission():
	print("intermission start!")
#	SoundtrackPlayer.pause_soundtrack()
	
	self.current_phase = PHASES.INTERMISSION
	emit_signal("wave_ended")
	
	$IntermissionTimer.start()
#	$UI/BattleUI/HBoxContainer/EnemiesLeft.hide()
#	$UI/BattleUI/HBoxContainer/TimeLeft.show()
	
	var wave_sound: AudioStreamPlayer = SfxPlayer.play_sfx(SFX_WAVE_END)
	if wave_sound:
		yield(wave_sound, "finished")
	SoundtrackPlayer.play_soundtrack(SoundtrackPlayer.THEMES.INTERMISSION)


func spawn_enemy():
	enemies_left_to_spawn -= 1
	
	# Spawn an enemy
	get_parent().spawn_enemy()
	enemies_alive += 1
	
	if enemies_left_to_spawn > 0:
		$EnemySpawnTimer.start()

func _on_EnemySpawnTimer_timeout():
	spawn_enemy()


func spawn_badge(pos: Vector2, faction: int = !current_player_faction):
	var badge = BADGE.instance()
	badge.init(faction)
	BADGES.add_child(badge)
	badge.global_position = pos
	badge.connect("picked", self, "badge_picked")

func spawn_all_bagdes_of_this_wave():
	var badge_positions: Array = enemy_death_positions.slice(enemies_total - (enemies_this_wave + 1), enemies_total - 1)
	for pos in badge_positions:
		spawn_badge(pos)

func badge_picked():
	badges_picked_this_wave += 1
	badges_picked_total += 1
	
	if badges_picked_this_wave == enemies_this_wave:
		# Show a notification that all the badges of this round were collected
		pass

func enemy_died(enemy: KinematicBody2D):
	enemy_death_positions.append(enemy.global_position)
	enemies_alive -= 1
	
	if enemies_alive < 1:
		start_intermission()


func _on_IntermissionTimer_timeout():
	start_battle()
