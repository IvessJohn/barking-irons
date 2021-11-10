extends "res://project/entities/EntityBase.gd"

var is_spawned = false # A variable for understanding if an enemy is fully spawned

var player: KinematicBody2D = null
var chosen_weaponItem: Node2D = null
var weapons_nearby: int = 0


export(bool) var FOLLOWS_PATH: bool = true

enum BEHAVIORS {
	NORMAL,		# Tries to reach a weapon first
	BERSERK,	# Attacks the player right away in melee combat
	COWARD,		# Always tries to pick weapons
	FIGHTER		# ONLY melee
}
export(BEHAVIORS) var CHOSEN_BEHAVIOR = BEHAVIORS.NORMAL
export(bool) var random_behavior: bool = false

var cur_target: Node2D = null

onready var hitlos = $HitLOS
onready var shootlos = $ShootLOS
onready var throwlos = $ThrowLOS
onready var pathfinder = $Pathfinder
var enemyNetwork = null


func _ready():
	yield(get_tree(), "idle_frame")
	var tree_cur_scene = get_tree().current_scene
	if tree_cur_scene.is_in_group("Level"):	
		player = tree_cur_scene.return_player()
		
		if get_tree().has_group("LevelNavigation"):
			pathfinder.levelNav = get_tree().get_nodes_in_group("LevelNavigation")[0]
		if get_tree().has_group("EnemyNetwork"):
			enemyNetwork = get_tree().get_nodes_in_group("EnemyNetwork")[0]
	
	
	if random_behavior:
		CHOSEN_BEHAVIOR = BEHAVIORS.values()[randi() % BEHAVIORS.size()]
	
	
	CHOSEN_BEHAVIOR = BEHAVIORS.NORMAL
#	CHOSEN_BEHAVIOR = BEHAVIORS.BERSERK
#	CHOSEN_BEHAVIOR = BEHAVIORS.COWARD
#	CHOSEN_BEHAVIOR = BEHAVIORS.FIGHTER

	match CHOSEN_BEHAVIOR:
		BEHAVIORS.NORMAL:
			pass
		BEHAVIORS.BERSERK:
			pass
		BEHAVIORS.COWARD:
			pass
		BEHAVIORS.FIGHTER:
			can_pick_up_items = false

func _should_chase_player():
	if CHOSEN_BEHAVIOR == BEHAVIORS.FIGHTER:
		return true
	if CHOSEN_BEHAVIOR == BEHAVIORS.BERSERK and weapons_nearby == 0:
		return true

func _should_look_for_weapon():
	if CHOSEN_BEHAVIOR == BEHAVIORS.FIGHTER or CHOSEN_BEHAVIOR == BEHAVIORS.BERSERK:
		return false
	else:
		if CHOSEN_BEHAVIOR == BEHAVIORS.COWARD:
			return current_armed_state == ARMED_STATES.UNARMED
		else:
			# BEHAVIORS.NORMAL
			return (weapons_picked == 0 or weapons_nearby > 0)

func _should_chase_weapon():
	return chosenweapon_exists()

func chosenweapon_exists():
	return is_instance_valid(chosen_weaponItem)

func _physics_process(_delta):
	if active:
		# Generating paths to either the revolver or the player
		if FOLLOWS_PATH and pathfinder:
			behave_as(CHOSEN_BEHAVIOR)
	#		if CHOSEN_BEHAVIOR != BEHAVIORS.BERSERK and is_instance_valid(chosen_weaponItem) and current_armed_state != ARMED_STATES.REVOLVER:
	#			# If the revolver is available on the map
	#			cur_target = chosen_weaponItem
	#		else:
	#			cur_target = player
			
	#		pathfinder.set_deferred("path", pathfinder.get_path_to_target(cur_target))
			go_to(cur_target)
		
		# Attacking
		if can_move and is_instance_valid(player):
			var direction_to_player = global_position.direction_to(player.global_position)
			hitlos.rotation = direction_to_player.angle()
			shootlos.rotation = hitlos.rotation
			throwlos.rotation = hitlos.rotation
			$ProjSpawnPivot.rotation = direction_to_player.angle()
			
			if check_player_in_detection(hitlos):
				attack_in_direction(direction_to_player, true)
			elif current_armed_state != ARMED_STATES.UNARMED:
				var checking_los: RayCast2D = shootlos
				if current_armed_state == ARMED_STATES.TORCH:
					checking_los = throwlos
					
				if check_player_in_detection(checking_los):
					attack_in_direction(direction_to_player, false)
	
	apply_and_decrease_knockback()
	move()

func go_to(target):
	pathfinder.generate_path_to_target(target)
	pathfinder.navigate()

func behave_as(behavior = CHOSEN_BEHAVIOR):
	# EXPLANATION: chosen_weaponItem contains a reference to the weapon item that
	# the enemy aims to pick up. When it's null, it means that the enemy
	# is currently not looking for a weapon
	
	match behavior:
		BEHAVIORS.NORMAL: #  Takes one weapon, then attacks the player. 
			# Doesn't care for more weapons, unless they are very close and it's 
			# no big deal going to them
			
			if (weapons_picked < 1 or weapons_nearby > 0) and !is_instance_valid(chosen_weaponItem):
				var chosen_weaponItem = find_closest_weapon(true, true)
				if is_instance_valid(chosen_weaponItem):
					cur_target = chosen_weaponItem
				return
			elif is_instance_valid(chosen_weaponItem) and cur_target.is_in_group("Pickables"):
				# No need to update cur_target because it is still chosen_weaponItem
				return
			
			# Already has or had a weapon
			cur_target = player
		
		BEHAVIORS.BERSERK: #  The main target is the player. Doesn't care for weapons, 
			# unless they are very close and it's no big deal going to them
			
			if weapons_nearby > 0 and !is_instance_valid(chosen_weaponItem):
				var chosen_weaponItem = find_closest_weapon(true, true)
				if is_instance_valid(chosen_weaponItem):
					cur_target = chosen_weaponItem
					return
#			elif cur_target.is_in_group("Pickables") and is_instance_valid(chosen_weaponItem):
#				# No need to update cur_target because it is still chosen_weaponItem
#				pass
			
			# Already has or had a weapon
			cur_target = player
		
		BEHAVIORS.COWARD: #  Constantly seeks for weapons. 
			# If there are no weapons, only then directly goes to the player and 
			# fights melee
			
			if enemyNetwork.count_unclaimed_weapons() > 0 and !is_instance_valid(chosen_weaponItem):
				var chosen_weaponItem = find_closest_weapon(true, true)
				if is_instance_valid(chosen_weaponItem):
					cur_target = chosen_weaponItem
				return
			elif is_instance_valid(chosen_weaponItem) and cur_target.is_in_group("Pickables"):
				# No need to update cur_target because it is still chosen_weaponItem
				return
			
			# Already has a weapon or there are none available
			cur_target = player
		
		BEHAVIORS.FIGHTER: #  Doesn't seek for weapons at all. ONLY melee attacks
			cur_target = player


func check_player_in_detection(wanted_los: RayCast2D) -> bool:
	var collider = wanted_los.get_collider()
	if collider and collider.is_in_group("Player"):
#		print(wanted_los.name + " raycast collided")	# Debug purposes
		return true
	return false


func null_chosen_weaponItem():
	chosen_weaponItem = null
	erase_claimed_weapon()

func find_closest_weapon(check_revolvers: bool = true, check_torches: bool = false, check_sawedoffs: bool = true):
	var chosen_weaponItems_list: Array = []
	var closest_weapon = null
	var closest_dist = -1
	
	if check_revolvers:
		chosen_weaponItems_list.append_array(get_tree().get_nodes_in_group("RevolverItem"))
	if check_torches:
		chosen_weaponItems_list.append_array(get_tree().get_nodes_in_group("TorchItem"))
	if check_sawedoffs:
		chosen_weaponItems_list.append_array(get_tree().get_nodes_in_group("SawedOffItem"))
	
	for chosen_weaponItem in chosen_weaponItems_list:
		if is_instance_valid(enemyNetwork):
			if str(chosen_weaponItem) in enemyNetwork.claimed_weaponItems.keys():
				continue
		
		var dist_to_item = global_position.distance_squared_to(chosen_weaponItem.global_position)
		if dist_to_item < closest_dist or closest_dist < 0:
			closest_weapon = chosen_weaponItem
			closest_dist = dist_to_item
	
	claim_weapon(closest_weapon)
	
	return closest_weapon

func claim_weapon(weapon):
	if weapon != null and is_instance_valid(enemyNetwork) and !(str(weapon) in enemyNetwork.claimed_weaponItems.keys()):
		enemyNetwork.claimed_weaponItems[str(weapon)] = self


func _on_WeaponDetectionArea_area_entered(area):
	if area.is_in_group("chosen_weaponItem") and !(str(area) in enemyNetwork.claimed_weaponItems.keys()):
		weapons_nearby += 1
		var path_to_the_weapon = pathfinder.get_path_to_target(area)
		var path_dist = pathfinder.calculate_path_distance(path_to_the_weapon)
#		print("Distance to the weapon " + area.name + ": " + str(path_dist))

func _on_WeaponDetectionArea_area_exited(area):
	if area.is_in_group("chosen_weaponItem") and !(str(area) in enemyNetwork.claimed_weaponItems.keys()):
		weapons_nearby -= 1

func erase_claimed_weapon():
	if is_instance_valid(enemyNetwork):
		if str(chosen_weaponItem) in enemyNetwork.claimed_weaponItems.keys():
			enemyNetwork.claimed_weaponItems.erase(str(chosen_weaponItem))

