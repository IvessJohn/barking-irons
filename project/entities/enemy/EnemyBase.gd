extends "res://project/entities/EntityBase.gd"


var player: KinematicBody2D = null
var revolverItem: Node2D = null

export(bool) var FOLLOWS_PATH: bool = true

enum AI_LEVELS {
	EASY = 60,
	NORMAL = 45,
	DIFFICULT = 30
}

enum BEHAVIORS {
	NORMAL,	# Tries to reach the pistol first
	BERSERK	# Attacks the player right away in melee combat
}
export(BEHAVIORS) var CHOSEN_BEHAVIOR = BEHAVIORS.NORMAL
export(bool) var random_behavior: bool = false

onready var hitlos = $HitLOS
onready var shootlos = $ShootLOS
onready var pathfinder = $Pathfinder


func _ready():
	yield(get_tree(), "idle_frame")
	if get_tree().has_group("Player"):
		player = get_tree().get_nodes_in_group("Player")[0]
	if get_tree().has_group("RevolverItem"):
		revolverItem = get_tree().get_nodes_in_group("RevolverItem")[0]
	if get_tree().has_group("LevelNavigation"):
		pathfinder.levelNav = get_tree().get_nodes_in_group("LevelNavigation")[0]
	
	if random_behavior:
		CHOSEN_BEHAVIOR = BEHAVIORS.values()[randi() % BEHAVIORS.size()]

func _physics_process(_delta):
	# Generating paths to either the revolver or the player
	if FOLLOWS_PATH and pathfinder:
		if CHOSEN_BEHAVIOR != BEHAVIORS.BERSERK and revolverItem and current_armed_state != ARMED_STATES.REVOLVER:
			# If the revolver is available on the map
			pathfinder.generate_path_to_target(revolverItem)
		else:
			pathfinder.generate_path_to_target(player)
		
		pathfinder.navigate()
	
	# Attacking
	if player != null:
		var direction_to_player = global_position.direction_to(player.global_position)
		hitlos.rotation = direction_to_player.angle()
		shootlos.rotation = direction_to_player.angle()
		$ProjSpawnPivot.rotation = direction_to_player.angle()
		
		if check_player_in_detection(hitlos):
			attack_in_direction(direction_to_player, true)
		elif check_player_in_detection(shootlos):
			attack_in_direction(direction_to_player, false)
	
	apply_and_decrease_knockback()
	move()

func check_player_in_detection(wanted_los: RayCast2D) -> bool:
	var collider = wanted_los.get_collider()
	if collider and collider.is_in_group("Player"):
#		print(wanted_los.name + " raycast collided")	# Debug purposes
		return true
	return false

func null_revolverItem():
	revolverItem = null
