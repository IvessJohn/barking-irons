extends "res://project/utilities/StateMachine.gd"

func _ready():
	add_state("chase_player")
	add_state("choosing_weapon")
	add_state("chasing_weapon")
	call_deferred("set_state", states.choosing_weapon)

func _state_logic(delta):
	pass

func _get_transition(delta):
	match state:
		states.chase_player:
			if parent._should_look_for_weapon():
				return states.choosing_weapon
		states.choosing_weapon:
			if parent._should_chase_player():
				return states.chase_player
		states.chasing_weapon:
			if parent._should_chase_weapon() == false:
				return states.chase_player
	
	return null

func _exit_state(old_state, new_state):
	pass

func _enter_state(new_state, old_state):
	print(name + " entered the " + str(new_state) + " state")
	pass
