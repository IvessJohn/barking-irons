extends "res://project/utilities/StateMachine.gd"

func _ready():
	add_state("chase_player")
	add_state("choosing_weapon")
	add_state("chase_weapon")
	call_deferred("set_state", states.chase_player)

func _state_logic(delta):
	if parent.active:
		# Generating paths to either the revolver or the player
		if parent.FOLLOWS_PATH and parent.pathfinder:
			match state:
				states.chase_player:
					parent.go_to(parent.player)
				states.choosing_weapon:
					parent.stop_navigation()
				states.chase_weapon:
					parent.go_to(parent.chosen_weaponItem)
			
#			parent.go_to(parent.cur_target)
		
		# Attacking
		if parent.can_move and is_instance_valid(parent.player):
			var direction_to_player = parent.global_position.direction_to(parent.player.global_position)
			parent.hitlos.rotation = direction_to_player.angle()
			parent.shootlos.rotation = parent.hitlos.rotation
			parent.throwlos.rotation = parent.hitlos.rotation
			parent.projSpawnPivot.rotation = direction_to_player.angle()
			
			if parent.check_player_in_detection(parent.hitlos):
				parent.attack_in_direction(direction_to_player, true)
			elif parent.current_armed_state != parent.ARMED_STATES.UNARMED:
				var checking_los: RayCast2D = parent.shootlos
				if parent.current_armed_state == parent.ARMED_STATES.TORCH:
					checking_los = parent.throwlos
					
				if parent.check_player_in_detection(checking_los):
					parent.attack_in_direction(direction_to_player, false)
	
	parent.apply_and_decrease_knockback()
	parent.move()

func _get_transition(delta):
	match state:
		states.chase_player:
			if parent._should_look_for_weapon():
				return states.choosing_weapon
		states.choosing_weapon:
			if parent._should_chase_weapon():
				return states.chase_weapon
			elif parent._should_chase_player():
				return states.chase_player
		states.chase_weapon:
			if parent._should_chase_weapon() == false:
				return states.chase_player
	
	return null

func _exit_state(old_state, new_state):
	pass

func _enter_state(new_state, old_state):
	print(name + "'s new state's ID is " + str(new_state))
	match state:
		states.chase_player:
			# chasing_target = player
			parent.cur_target = parent.player
		states.choosing_weapon:
			# find a weaponItem
			var weaponItem = parent.find_closest_weapon()
			parent.chosen_weaponItem = weaponItem
		states.chase_weapon:
			# if weapon exists then chasing_target = weaponItem
			if parent.chosenweapon_exists():
				parent.cur_target = parent.chosen_weaponItem
